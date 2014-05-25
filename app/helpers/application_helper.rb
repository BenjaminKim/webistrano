# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nice_flash(text)
    render(partial: 'layouts/flash', locals: {text: text})
  end

  def error_flash(text)
    render(partial: 'layouts/flash_error', locals: {text: text})
  end
  
  def locking_flash(text)
    render(partial: 'layouts/flash_locking', locals: {text: text})
  end
  
  def flashed_errors(object_name)
    obj = instance_variable_get("@#{object_name}")
    return nil if obj.errors.blank?
    
    error_messages = obj.errors.full_messages.map {|msg| content_tag(:li, msg)}

    html = content_tag(:p,"#{pluralize(obj.errors.size, 'error')} prohibited this #{object_name.to_s.gsub('_', ' ')} from being saved")
    error_messages.each do |msg|
      html << content_tag(:div, content_tag(:ul, msg))
    end
    
    content_for(:flash_content) do                   
      error_flash(html.html_safe)
    end
  end
  
  def web_friendly_text(text)
    return text if text.blank?
    h(text).gsub("\n",'<br>').gsub("\r",'')
  end
  
  def hide_password_in_value(config)
    if !config.prompt? && config.name.match(/password/) 
      '************'
    else
      config.value || ''
    end
  end
  
  def current_stage_project_description
    "stage: #{link_to h(current_stage.name), project_stage_path(current_project, current_stage)} (of project #{link_to h(current_project.name), project_path(current_project)})"
  end
  
  # returns the open/closed status of a menu
  # either the active controller is used or the given status is returned
  def controller_in_use_or(contr_name, status, klass)
    if @controller.is_a? contr_name
      :open
    else
      if status == :closed && (klass.count <= 3 )
        # the box should be closed
        # open it anyway if we have less than three
        status = :open
      end
  
      status
    end
  end
  
  # returns the display:none/visible attribute
  # if the stages of a project should be shown
  def show_stages_of_project(project)
    a_stage_active = false
    
    # check each stage
    project.stages.each do |stage|
      a_stage_active = true unless active_link_class(stage).blank?
    end
    
    # check project
    a_stage_active = true unless active_link_class(project).blank?
    
    a_stage_active ? '' : 'display:none;'
  end
  
  # negation of show_stages_of_project(project)
  def do_not_show_stages_of_project(project)
    if show_stages_of_project(project).blank?
      'display:none;'
    else
      ''
    end
  end
  
  def user_info(user)
    link_to user.login, user_path(user)
  end
  
  def show_if_closed(status)
    status != :closed ?  'display:none;' : ''
  end
  
  def show_if_opened(status)
    status != :open ?  'display:none;' : ''
  end
  
  # returns a CSS class if the current item is an active item
  def active_link_class(item)
    active_class = 'active_menu_link'
    found = false
    case item.class.to_s
    when 'Project'
      found = true if (@project && @project == item) && (@stage.blank?)
    when 'Host'
      found = true if @host && @host == item
    when 'Recipe'
      found = true if @recipe && @recipe == item
    when 'User'
      found = true if @user && @user == item
    when 'Stage'
      found = true if @stage && @stage == item
    end
    
    if found
      active_class
    else
      ''
    end
  end
  
  def breadcrumb_box(&block)
    content_tag :div, class: 'breadcrumb' do
      content_tag :b do
        capture(&block) if block
      end
    end
  end

  def tree_brnach_draw(branch)
    (
    if branch[:children].nil?
      <<-LEAF
        <div class="branch" #{"id=#{branch[:id]}" if branch[:id]}>
            <span class="glyphicon glyphicon-leaf" style="padding-left: 5px"></span>
            <a href="#{branch[:link]}" style="padding-left: 5px" title="#{branch[:name]}" >#{branch[:name]}</a>
        </div>
      LEAF
    else
      children_html = branch[:children].inject '' do |aggregater, child|
        aggregater += tree_brnach_draw(child)
      end
      <<-TREE
        <div class="branch" #{"id=#{branch[:id]}" if branch[:id]}>
            <button class="branch-toggler naked">
                <span class="branch-toggler glyphicon glyphicon-plus"></span>
            </button>
            <a href="#{branch[:link]}">#{branch[:name]}</a>
            <div class="tree" hidden="hidden" style="padding-left: 15px">
              #{children_html}
            </div>
        </div>
      TREE
    end
    ).html_safe
  end

  def page_title_helper(title, description)
    (<<-TITLE
    <div class="row">
        <div class="col-md-6"><span class="label label-primary">#{title}</span></div>
        <div class="col-md-6" align="right">#{description}</div>
    TITLE
    ).html_safe
  end

  def new_button_for_ajax(url)
    (<<-BUTTON
    <button class="btn btn-xs btn-success" rel="ajaxModal" data-url="#{url}">
        <i class="glyphicon glyphicon-edit"></i> #{I18n.t 'helpers.new'}
    </button>
    BUTTON
    ).html_safe
  end

  def new_button(url)
    (<<-BUTTON
    <a href="#{url}" class="btn btn-xs btn-success">
      <i class="glyphicon glyphicon-edit"></i> #{I18n.t 'helpers.new'}
    </a>
    BUTTON
    ).html_safe
  end

  def view_button(url)
    (<<-BUTTON
    <a href="#{url}" class="btn btn-xs btn-info">
      <i class="glyphicon glyphicon-eye-open"></i> #{I18n.t 'helpers.view'}
    </a>
    BUTTON
    ).html_safe
  end

  def edit_button(url)
    (<<-BUTTON
    <a href="#{url}" class="btn btn-xs btn-primary">
      <i class="glyphicon glyphicon-edit"></i> #{I18n.t 'helpers.edit'}
    </a>
    BUTTON
    ).html_safe
  end

  def edit_button_for_ajax(url)
    (<<-BUTTON
    <button class="btn btn-xs btn-primary" rel="ajaxModal" data-url="#{url}">
        <i class="glyphicon glyphicon-edit"></i> #{I18n.t 'helpers.edit'}
    </button>
    BUTTON
    ).html_safe
  end

  def clone_button_for_ajax(url)
    (<<-BUTTON
    <button class="btn btn-xs btn-warning" rel="ajaxModal" data-url="#{url}">
        <i class="glyphicon glyphicon-share"></i> #{I18n.t 'helpers.clone'}
    </button>
    BUTTON
    ).html_safe
  end

  def delete_button_for_ajax(url, delete_target_name, confirm_message = I18n.t('helpers.links.confirm'))
    (<<-BUTTON
    <button class="btn btn-xs btn-danger" rel="ajaxModalConfirm" data-url="#{url}" data-method="delete" data-title="#{I18n.t 'helpers.titles.delete', model: delete_target_name}" data-message="#{confirm_message}">
        <i class="glyphicon glyphicon-trash"></i> #{I18n.t 'helpers.delete'}
    </button>
    BUTTON
    ).html_safe
  end
end
