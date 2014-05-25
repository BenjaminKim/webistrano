class DeploymentsController < ApplicationController
  
  before_filter :load_stage
  before_filter :ensure_deployment_possible, only: [:new, :create]

  # GET /projects/1/stages/1/deployments
  # GET /projects/1/stages/1/deployments.xml
  def index
    @deployments = @stage.deployments

    respond_to do |format|
      format.html
      format.xml  { render xml: @deployments.to_xml }
    end
  end

  # GET /projects/1/stages/1/deployments/1
  # GET /projects/1/stages/1/deployments/1.xml
  def show
    @deployment = @stage.deployments.find(params[:id])
    set_auto_scroll
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @deployment.to_xml }
    end
  end

  # GET /projects/1/stages/1/deployments/new
  def new
    @deployment = @stage.deployments.new
    @deployment.task = params[:task]
    
    if params[:repeat]
      @original = @stage.deployments.find(params[:repeat])
      @deployment = @original.repeat
    end
  end

  # POST /projects/1/stages/1/deployments
  # POST /projects/1/stages/1/deployments.xml
  def create
    @deployment = Deployment.new

    respond_to do |format|
      if populate_deployment_and_fire
        use_krb = !session[:kerberos].nil?
        if use_krb
          begin
            data = SessionsHelper::decrypt(Base64.decode64(session[:kerberos]))
            data = ActiveSupport::JSON.decode(data)
            username = data['username']
            password = data['password']
          rescue
            use_krb =false
          end
        end

        @deployment.deploy_in_background!({kerberos: use_krb, username: username, password: password})

        format.html { redirect_to project_stage_deployment_url(@project, @stage, @deployment)}
        format.xml  { head :created, location: project_stage_deployment_url(@project, @stage, @deployment) }
      else
        @deployment.clear_lock_error
        format.html { render action: :new }
        format.xml  { render xml: @deployment.errors.to_xml }
      end
    end
  end

  # GET /projects/1/stages/1/deployments/latest
  def latest
    @deployment = @stage.deployments.order('created_at desc').first

    respond_to do |format|
      format.html { render action: :show }
      format.xml do
        if @deployment
          render :xml => @deployment.to_xml
        else
          render :status => 404, :nothing => true
        end
      end
    end
  end
  
  # POST /projects/1/stages/1/deployments/1/cancel
  def cancel
    redirect_to "/" and return unless request.post?
    @deployment = @stage.deployments.order('created_at desc').first

    respond_to do |format|
      begin
        @deployment.cancel!
        
        flash[:notice] = "Cancelled deployment by killing it"
        format.html { redirect_to project_stage_deployment_url(@project, @stage, @deployment)}
        format.xml  { head :ok }
      rescue => e
        flash[:error] = "Cancelling failed: #{e.message}"
        format.html { redirect_to project_stage_deployment_url(@project, @stage, @deployment)}
        format.xml  do
          @deployment.errors[:base] = e.message
          render :xml => @deployment.errors.to_xml
        end
      end
    end
  end


  def status
    @deployment = @stage.deployments.find(params[:id])
    set_auto_scroll

    respond_to do |format|
      format.html { render partial: 'status' }
    end
  end
  
  protected
  def ensure_deployment_possible
    if current_stage.deployment_possible?
        true
    else
      respond_to do |format|  
        flash[:error] = 'A deployment is currently not possible.'
        format.html { redirect_to project_stage_url(@project, @stage) }
        format.xml  { render :xml => current_stage.deployment_problems.to_xml }
        false
      end
    end
  end

  def set_auto_scroll
    if params[:auto_scroll].to_s == 'true'
      @auto_scroll = true
    else
      @auto_scroll = false
    end
  end
  
  # sets @deployment
  def populate_deployment_and_fire
    Deployment.lock_and_fire do |deployment|
      @deployment = deployment
      @deployment.attributes = params[:deployment]
      @deployment.prompt_config = params[:deployment][:prompt_config] rescue {}
      @deployment.stage = current_stage
      @deployment.user = current_user
    end
  end
end
