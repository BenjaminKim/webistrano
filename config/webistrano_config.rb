# 
#  Example Webistarno configuration
#  
#  copy this file to config/webistrano.rb and edit
#
WebistranoConfig = {
  # Uncomment to use CAS authentication
  # :authentication_method => :cas,
  
  # SMTP settings for outgoing email
  :smtp_delivery_method => :smtp,
  
  :smtp_settings => {
    :address  => "mail.webistrano.com",
    :port  => 25, 
    :domain  => "webistrano.com",
    #:user_name  => "username",
    #:password  => "passwd",
    #:authentication  => :login
  },
  
  # Sender address for Webistrano emails
  :webistrano_sender_address => "webistrano@webistrano.com",
  
  # Sender and recipient for Webistrano exceptions
  :exception_recipients => "webistrano-subscriber@webistrano.com",
  :exception_sender_address => "webistrano@webistrano.com"

}
