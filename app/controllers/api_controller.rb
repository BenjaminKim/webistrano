class ApiController < ApplicationController
  skip_before_filter :login_required

  def hosts
    begin
      project = params[:project]
      stages = params[:stage].split(',')

      project = Project.find_by_name(project)
      ret = {}
      stages.each do |stage|
        ret[stage] = project.stages.find_by_name(stage).hosts.map(&:name)
      end

      render :json => {project.name => ret}
    rescue
      render :status => 400, :json => {'status' => 'invalid parameters'}
    end
  end
end
