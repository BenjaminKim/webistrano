# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

require 'open4'
require 'capistrano/cli'
require 'syntax/convertors/html'

# set default time_zone to UTC
ENV['TZ'] = 'UTC'
Time.zone = 'UTC'
