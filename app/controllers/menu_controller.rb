class MenuController < ApplicationController
  def list
    project_list = Project.order('name ASC').map do |project|
      body = {
          name: project.name,
          url: project_path(project)
      }
      body[:children] = project.stages.map do |stage|
        {
            name: stage.name,
            url: project_stage_path(project, stage)
        }
      end
      body
    end
    host_list =  Host.order('name ASC').map do |host|
      {
          name: host.name,
          id: host.id
      }
    end

    respond_to do |format|
      format.json do
        render json: {
            projects: {
                name: I18n.t('projects.title'),
                url: projects_path,
                children: project_list
            },
            hosts: {
                name: I18n.t('hosts.title'),
                url: hosts_path,
                children: host_list
            }
        }
      end
    end
  end
end