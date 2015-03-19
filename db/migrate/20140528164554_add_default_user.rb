class AddDefaultUser < ActiveRecord::Migration
  def self.up
    User.reset_column_information
    if User.count == 0
      User.create!(
        login: 'admin',
        email: 'admin@example.com',
        password: 'webistrano',
        password_confirm: 'webistrano',
        admin: 1
      )
    end
  end

  def self.down
  end
end
