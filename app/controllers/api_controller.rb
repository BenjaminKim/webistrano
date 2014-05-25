class ApiController < ApplicationController
  skip_before_filter :login_required

  def hosts
    begin
      project = params[:project]
      stages = params[:stage].split(',')

      project = Project.find_by_name(project)
      ret = {}
      stages.each do |stage_name|
        stage = project.stages.find_by_name(stage_name)
        no_releases = Role.find_all_by_stage_id(stage.id).select{|r| r.no_release == 1}.map(&:host_id) 
        ret[stage.name] = stage.hosts.select{|h| not no_releases.include? h.id}.map(&:name)
      end

      if params[:flatten] || params[:csshx]
        ret = ret.collect{|k,v| v}.flatten
      end

      if params[:csshx]
        render :text => ret.join(' ')
      else
        render :json => {project.name => ret}
      end
    rescue
      render :status => 400, :json => {'status' => 'invalid parameters'}
    end
  end
end
