class ApplicationController < ActionController::Base
#  before_filter CASClient::Frameworks::Rails::Filter if WebistranoConfig[:authentication_method] == :cas

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_filter :ensure_not_disabled
  before_filter :build_menu_tree
  around_filter :set_timezone

  layout 'application'
  
  helper :all # include all helpers, all the time
  helper_method :current_stage, :current_project

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:login, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:login, :password, :password_confirmation, :current_password) }
  end

  def set_timezone
    # default timezone is UTC
    Time.zone = user_signed_in? ? ( current_user.time_zone rescue 'UTC'): 'UTC'
    yield
    Time.zone = 'UTC'
  end
  
  def load_project
    @project = Project.find(params[:project_id])
  end
  
  def load_stage
    load_project
    @stage = @project.stages.find(params[:stage_id])
  end
  
  def current_stage
    @stage
  end
  
  def current_project
    @project
  end
  
  def ensure_admin
    if user_signed_in? && current_user.admin?
      return true
    else
      flash[:notice] = 'Action not allowed'
      redirect_to root_path
      return false
    end
  end
  
  def ensure_not_disabled
    if user_signed_in? && current_user.disabled?
      logout
      return false
    else
      return true
    end
  end

  def build_menu_tree
    project_branch = {
        name: I18n.t('helpers.projects'),
        link: projects_path,
        id: 'projects-branch'
    }

    project_branch[:children] = Project.order('name ASC').map do |project|
      body = {
          name: project.name,
          link: project_path(project),
          id: "project-#{project.id}-branch"
      }
      body[:children] = project.stages.map do |stage|
        {
            name: stage.name,
            link: project_stage_path(project, stage)
        }
      end
      body
    end

    host_branch = {
        name: I18n.t('helpers.hosts'),
        link: hosts_path,
        id: 'hosts-branch'
    }
    host_branch[:children] = Host.order('name ASC').map do |host|
      {
          name: host.name,
          link: host_path(host)
      }
    end

    recipe_branch = {
        name: I18n.t('helpers.recipes'),
        link: recipes_path,
        id: 'recipes-branch'
    }
    recipe_branch[:children] = Recipe.order('name ASC').map do |recipe|
      {
          name: recipe.name,
          link: recipe_path(recipe)
      }
    end
    @menu = [project_branch, host_branch, recipe_branch]
  end
  
  def logout
    self.current_user.forget_me! if user_signed_in?
    cookies.delete :auth_token
    reset_session
    if WebistranoConfig[:authentication_method] != :cas
      flash[:notice] = "You have been logged out."
      redirect_to root_path
    else
      redirect_to "#{CASClient::Frameworks::Rails::Filter.config[:logout_url]}?serviceUrl=#{home_url}"
    end
  end
end
