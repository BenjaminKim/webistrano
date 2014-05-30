class UsersController < ApplicationController
  before_filter :ensure_admin, only: [:new, :destroy, :create, :enable]
  before_filter :ensure_admin_or_my_entry, only: [:edit, :update]

  # GET /users
  # GET /users.xml
  def index
    @users = User.order 'login ASC'
  end

  # GET /users/new
  def new
    # render new.rhtml
    @user = User.new
    if request.xhr?
      render layout: false
    else
      render layout: true
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    if current_user.admin?
      @user.admin = params[:user][:admin].to_i rescue 0
    end

    respond_to do |format|
      if @user.save
        flash[:notice] = 'Account created'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :created, location: user_url(@user) }
      else
        format.html { render action: 'new' }
        format.xml  { render xml: @user.errors.to_xml }
      end
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @deployments = @user.recent_deployments

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render xml: @user.to_xml }
    end
  end

  # GET /users/edit/1
  def edit
    @user = User.find(params[:id])
    if request.xhr?
      render layout: false
    else
      render layout: true
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    user_param = params[:user]

    password = user_param.delete(:password)
    password_cofirmation = user_param.delete(:password_confirmation)

    if password && password_cofirmation
      @user.reset_password(password, password_cofirmation)
    end

    if current_user.admin?
      if user_param.delete(:admin).to_i == 1
        @user.make_admin!
      else
        @user.revoke_admin!
      end
    end

    @user.attributes = user_param

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        format.html {
          flash[:error] = @user.errors. full_messages
          raise 'asdf'
          redirect_to users_path
        }
        format.xml  { render xml: @user.errors.to_xml }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])

    if @user.admin? && User.admin_count == 1
      message = 'Can not disable last admin user.'
    else
      @user.disable
      message = 'User was successfully disabled.'
    end

    respond_to do |format|
      flash[:notice] = message
      format.html { redirect_to users_url }
      format.xml  { head :ok }
    end
  end

  def enable
    @user = User.find(params[:id])
    @user.enable
    flash[:notice] = 'The user was enabled'

    respond_to do |format|
      format.html { redirect_to users_path }
      format.xml  { head :ok }
    end
  end

  # GET /users/1/deployments
  # GET /users/1/deployments.xml
  def deployments
    @user = User.find(params[:id])
    @deployments = @user.deployments

    respond_to do |format|
      format.html # deployments.rhtml
      format.xml  { render xml: @user.deployments.to_xml }
    end
  end

  protected
  def ensure_admin_or_my_entry
    if current_user.admin? || current_user.id == User.find(params[:id]).id
      return true
    else
      redirect_to home_url
      return false
    end
  end
end
