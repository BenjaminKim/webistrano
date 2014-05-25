Webistrano2
===========

Capistrano deployment the easy way

Webistrano is a Web UI for managing Capistrano deployments.<br>
It lets you manage projects and their stages like test, production, <br>
and staging with different settings.<br>
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
  Webistrano is then available at http://host:3000/

  The default user is `admin`, the password is `admin`. Please change the password after the first login.

## Minimum requirement

* ruby version >= 2.0
