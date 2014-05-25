class HostsController < ApplicationController
  before_filter :ensure_admin, :only => [:new, :edit, :destroy, :create, :update]
  PAGE_SIZE = 100

  helper_method :pager_calculater
  # GET /hosts
  # GET /hosts.json
  def index
    @page = params[:page].nil? ? 1 : params[:page].to_i
    @page_max = Host.count / PAGE_SIZE
    @all_hosts = Host.order('name ASC')
    @count = @all_hosts.count
    @hosts = @all_hosts.offset((@page - 1) * PAGE_SIZE).limit(PAGE_SIZE)

    respond_to do |format|
      format.html
      format.json { render json: @all_hosts.to_json }
    end
  end

  def search
    @key = params[:key] || ''
    @page = params[:page].to_i || 0
    @all_hosts = Host.where(["name LIKE :tag", {tag: "%#{@key}%"}]).order('name ASC')
    @count = @all_hosts.count
    @hosts = @all_hosts.offset(@page * PAGE_SIZE).limit(PAGE_SIZE)
    @page_max = @all_hosts.count / PAGE_SIZE
    respond_to do |format|
      format.html { render action: 'index' }
      format.json { render json: @all_hosts.to_json }
    end
  end

  # GET /hosts/1
  # GET /hosts/1.xml
  def show
    @host = Host.find(params[:id])
    @stages = @host.stages.uniq.sort_by{|x| x.project.name}

    respond_to do |format|
      format.html
      format.xml { render :xml => @host.to_xml }
    end
  end

  # GET /hosts/new
  def new
    @host = Host.new
    render layout: false
  end

  # GET /hosts/1;edit
  def edit
    @host = Host.find(params[:id])
    render layout: false
  end

  # POST /hosts
  # POST /hosts.xml
  def create
    @host = Host.new(params[:host])

    respond_to do |format|
      if @host.save
        flash[:notice] = 'Host was successfully created.'
        format.html { redirect_to host_url(@host) }
        format.xml  { head :created, :location => host_url(@host) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @host.errors.to_xml }
      end
    end
  end

  # PUT /hosts/1
  # PUT /hosts/1.xml
  def update
    @host = Host.find(params[:id])

    respond_to do |format|
      if @host.update_attributes(params[:host])
        flash[:notice] = 'Host was successfully updated.'
        format.html { redirect_to host_url(@host) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @host.errors.to_xml }
      end
    end
  end

  # DELETE /hosts/1
  # DELETE /hosts/1.xml
  def destroy
    @host = Host.find(params[:id])
    @host.destroy

    respond_to do |format|
      flash[:notice] = 'Host was successfully deleted.'
      format.html { redirect_to hosts_url }
      format.xml  { head :ok }
    end
  end

  private
  PAGER_WINDOW_SIZE = 10
  def pager_calculater(pivot, page_count)
    min = [1, pivot - PAGER_WINDOW_SIZE / 2].max
    max = [min + PAGER_WINDOW_SIZE, page_count].min
    before_pivot = [1, min - PAGER_WINDOW_SIZE / 2].max
    after_pivot = [max + PAGER_WINDOW_SIZE / 2, page_count].min
    return min, max, before_pivot, after_pivot
  end
end
