require 'popen4'

class Deployment < ActiveRecord::Base
  belongs_to :stage
  belongs_to :user
  has_and_belongs_to_many :roles
  
  validates_presence_of :task, :stage, :user
  validates_length_of :task, maximum: 250
  
  serialize :excluded_host_ids
  
  attr_accessible :task, :prompt_config, :description, :excluded_host_ids, :override_locking
    
  # given configuration hash on create in order to satisfy prompt configurations
  attr_accessor :prompt_config
  
  attr_accessor :override_locking
  
  after_create :add_stage_roles
  
  DEPLOY_TASKS    = ['deploy', 'deploy:default', 'deploy:migrations']
  SETUP_TASKS     = ['deploy:setup']
  STATUS_CANCELED = 'canceled'
  STATUS_FAILED   = 'failed'
  STATUS_SUCCESS  = 'success'
  STATUS_RUNNING  = 'running'
  STATUS_VALUES   = [STATUS_SUCCESS, STATUS_FAILED, STATUS_CANCELED, STATUS_RUNNING]
  
  validates_inclusion_of :status, :in => STATUS_VALUES
    
  # check (on on creation ) that the stage is ready
  # his has to done only on creation as later DB logging MUST always work
  def validate_on_create
    unless self.stage.blank?
      errors[:stage] = 'is not ready to deploy' unless self.stage.deployment_possible?
      
      self.stage.prompt_configurations.each do |conf|
        errors[:base] = "Please fill out the parameter '#{conf.name}'" unless !prompt_config.blank? && !prompt_config[conf.name.to_sym].blank?
      end
      
      errors[:lock] = 'The stage is locked' if self.stage.locked? && !self.override_locking
      
      ensure_not_all_hosts_excluded
    end
  end
  
  def self.lock_and_fire
    transaction do
      d = Deployment.new
      yield d
      return false unless d.valid?
      stage = Stage.lock.find(d.stage_id)
      stage.lock
      d.save!
      stage.lock_with(d)
    end
    true
  rescue => e
    logger.debug "DEPLOYMENT: could not fire deployment: #{e.inspect} #{e.backtrace.join("\n")}"
    false
  end
  
  def override_locking?
    @override_locking.to_i == 1
  end
  
  def prompt_config
    @prompt_config = @prompt_config || {}
    @prompt_config
  end
  
  def effective_and_prompt_config
    @effective_and_prompt_config = @effective_and_prompt_config || self.stage.effective_configuration.collect do |conf|
      if prompt_config.has_key?(conf.name)
        conf.value = prompt_config[conf.name]
      end
      conf
    end
  end
  
  def add_stage_roles
    self.stage.roles.each do |role|
      self.roles << role
    end
  end
  
  def completed?
    !self.completed_at.blank?
  end
  
  def success?
    self.status == STATUS_SUCCESS
  end
  
  def failed?
    self.status == STATUS_FAILED
  end
  
  def canceled?
    self.status == STATUS_CANCELED
  end
  
  def running?
    self.status == STATUS_RUNNING
  end
  
  def status_in_html
    "<span class=\"deployment_status_#{self.status.gsub(/ /, '_')}\">#{self.status}</span>"
  end

  def complete_with_error!
    save_completed_status!(STATUS_FAILED)
    notify_per_mail
  end
  
  def complete_successfully!
    save_completed_status!(STATUS_SUCCESS)
    notify_per_mail
  end
  
  def complete_canceled!
    save_completed_status!(STATUS_CANCELED)
    notify_per_mail
  end
  
  # deploy through Webistrano::Deployer in background (== other process)
  # TODO - at the moment `Unix &` hack
  def deploy_in_background! (opts={})
    unless Rails.env == 'test'
      logger.info "Calling other ruby process in the background in order to deploy deployment #{self.id} (stage #{self.stage.id}/#{self.stage.name})"
      system_command = "sh -c \"cd #{Rails.root} && bundle exec rails runner -e #{Rails.env} ' deployment = Deployment.find(#{self.id}); deployment.prompt_config = #{self.prompt_config.inspect.gsub('"', '\"')} ; Webistrano::Deployer.new(deployment).invoke_task! ' >> #{Rails.root}/log/#{Rails.env}.log 2>&1\" &"
      logger.info "SYSTEM_COMMAND: #{system_command}"
      system(system_command)

      # Webistrano::Deployer.new(Deployment.find(self.id)).invoke_task!
    end
  end

  #require 'net/ssh/authentication/methods/gssapi_with_mic'
  #Net::SSH.start('tiger246.kr2.iwilab.com', 'deploy', {:auth_methods => ["gssapi-with-mic"], verbose: Logger::DEBUG}) do |ssh|
  #  puts ssh.exec!('hostname')
  #end

  # returns an unsaved, new deployment with the same task/stage/description
  def repeat
    deployment = Deployment.new
    deployment.stage = self.stage
    deployment.task = self.task
    deployment.description = "Repetition of deployment #{self.id}: \n"
    deployment.description += self.description
    return deployment
  end
  
  # returns a list of hosts that this deployment
  # will deploy to. This computed out of the list
  # of given roles and the excluded hosts
  def deploy_to_hosts
    all_hosts = self.roles.map(&:host).uniq
    return all_hosts - self.excluded_hosts
  end
  
  # returns a list of roles that this deployment
  # will deploy to. This computed out of the list
  # of given roles and the excluded hosts
  def deploy_to_roles(base_roles=self.roles)
    base_roles.dup.select { |role| not self.excluded_hosts.include?(role.host) }
  end
  
  # a list of all excluded hosts for this deployment
  # see excluded_host_ids
  def excluded_hosts
    res = []
    self.excluded_host_ids.each do |h_id|
      res << (Host.find(h_id) rescue nil)
    end
    res.compact
  end
  
  def excluded_host_ids
    self.read_attribute('excluded_host_ids').blank? ? [] : self.read_attribute('excluded_host_ids')
  end
  
  def excluded_host_ids=(val)
    val = [val] unless val.is_a?(Array)
    self.write_attribute('excluded_host_ids', val.map(&:to_i))
  end
  
  def cancelling_possible?
    !self.pid.blank? && !completed?
  end
  
  def cancel!
    raise 'Canceling not possible: Either no PID or already completed' unless cancelling_possible?
    
    Process.kill('SIGINT', self.pid)
    sleep 2
    Process.kill('SIGKILL', self.pid) rescue nil # handle the case that we killed the process the first time

    ccfile = File.join(Dir.tmpdir, "KAKAOAUTH.#{self.id}")
    FileUtils.remove_file(ccfile) rescue nil
    
    complete_canceled!
  end

  def clear_lock_error
    self.errors.delete(:lock)
  end

  def file_logger
    if @logger
      @logger
    else
      @logger = File.new(log_file_name, 'a')
      @logger.sync = true
      @logger
    end
  end

  def log(length=65536)
    if File.exist? log_file_name
      if length > 0
        `tail -c #{length} #{log_file_name}`
      else
        `cat #{log_file_name}`
      end
    else
      read_attribute(:log)
    end
  end
  
  protected
  def log_file_name
    "#{Rails.root}/log/deploy/#{self.id}.log"
  end

  def ensure_not_all_hosts_excluded
    unless self.stage.blank? || self.excluded_host_ids.blank?
      if deploy_to_roles(self.stage.roles).blank?
        errors[:base] = 'You cannot exclude all hosts.'
      end
    end
  end
  
  def save_completed_status!(status)
    raise 'cannot complete a second time' if self.completed?
    transaction do
      stage = Stage.lock.find(self.stage_id)
      stage.unlock
      self.status = status
      self.completed_at = Time.now
      self.log = log
      self.save!
    end
  end
  
  def notify_per_mail
    self.stage.emails.each do |email|
      Notification.deliver_deployment(self, email)
    end
  end
end
