class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable,
         :validatable, :authentication_keys => [:login]

  has_many :deployments, -> { order 'created_at DESC' }, dependent: :nullify
  validates :login,
            uniqueness: {
              case_sensitive: false
            }

  attr_accessible :login, :email, :password, :password_confirmation, :admin, :time_zone, :remember_me

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(login: login.downcase).first
    else
      where(conditions).first
    end
  end

  def admin?
    self.admin.to_i == 1
  end
  
  def revoke_admin!
    self.admin = 0
    self.save!
  end
  
  def make_admin!
    self.admin = 1
    self.save!
  end
  
  def self.admin_count
    where('admin = 1 AND disabled IS NULL').count
  end
  
  def recent_deployments(limit=3)
    self.deployments.order('created_at DESC').limit(limit)
  end
  
  def disabled?
    !self.disabled.blank?
  end
  
  def disable
    self.update_attribute(:disabled, Time.now)
    self.forget_me!
  end
  
  def enable
    self.update_attribute(:disabled, nil)
  end

  def migrated?
    self.migrated
  end
end
