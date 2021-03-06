Webistrano4
===========

[![Join the chat at https://gitter.im/BenjaminKim/webistrano](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/BenjaminKim/webistrano?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Webistrano4 is fork of Webistrano. Webistrano was cool but is hasn't been maintained so long, we decided to fork it. Webistrano reborned with Ruby 2.2, Rails 4 and Bootstrap 3.

Capistrano deployment the easy way

Webistrano is a Web UI for managing Capistrano deployments.  
It lets you manage projects and their stages like test, production,  
and staging with different settings.  
Those stages can then be deployed with Capistrano through Webistrano.

## Installation

* Configuration

  Copy config/webistrano_config.rb.sample to config/webistrano_config.rb
  and edit appropriatly. In this configuration file you can set the mail
  settings of Webistrano.

* Database

  Copy config/database.yml.sample to config/database.yml and edit to
  resemble your setting. You need at least the production database.
  The others are optional entries for development and testing.

  Then create the database structure with Rake:

  ```
  > cd webistrano
  > RAILS_ENV=production rake db:migrate
  ```

* Setup default capistrano environment
  + install sshpass

  + setup cache directory

    ```
    > sudo mkdir -p /var/cache/webistrano
    > chown -R user:group
    ```

* Start Webistrano

  ```
  > cd webistrano
  > bundle exec rails server -p 3000 -e production
  ```
  Webistrano is then available at http://localhost:3000/

  The default user is `admin`, the password is `webistrano`. Please change the password after the first login.

## Minimum requirement

* ruby version >= 2.0
