# == INITIAL CONFIG ==============

require 'mongrel_cluster/recipes'

set :runner, "root"
set :use_sudo, :true

set :domain, Capistrano::CLI.ui.ask("deployment server hostname (e.g. weke.its.yale.edu): ")
set :application, "Shifts_Payform"
set :application_prefix, Capistrano::CLI.ui.ask("deployment application prefix (e.g. shifts_payform): ")

set :keep_releases, 10
set :repository,  "svn://mahi.its.yale.edu/shifts_payform/stc/trunk"
set :scm, :subversion
set :deploy_to, "/srv/www/htdocs/rails/#{application_prefix}"
set :shared_path, "#{deploy_to}/shared"

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

role :app, "#{domain}"
role :web, "#{domain}"
role :db,  "#{domain}", :primary => true


# == CONFIG ====================================================================
# == SET UP DB STUFF, MONGREL CONFIG

namespace :init do
  namespace :config do
    desc "Create database.yml"
    task :database do
      set :mysql_user, Capistrano::CLI.ui.ask("deployment host database user name: ")
      set :mysql_pass, Capistrano::CLI.password_prompt("deployment host database password: ")
      database_configuration =<<-EOF
---
production:
  adapter: mysql
  database: #{application}_#{application_prefix}_production
  host: localhost
  user: #{mysql_user}
  password: #{mysql_pass}

EOF
      run "mkdir -p #{shared_path}/config"
      put database_configuration, "#{shared_path}/config/database.yml"
    end

    desc "Create mongrel_cluster.yml"
    task :mongrel do
      set :starting_port, Capistrano::CLI.ui.ask("starting port number (e.g 8000): ")
      mongrel_cluster_configuration = <<-EOF
--- 
cwd: #{current_path}
prefix: /#{application_prefix}
log_file: #{current_path}/log/mongrel.log
port: #{starting_port}
environment: production
address: 127.0.0.1
pid_file: #{current_path}/tmp/pids/mongrel.pid
servers: 3
EOF
      run "mkdir -p #{shared_path}/config"
      put mongrel_cluster_configuration, "#{shared_path}/config/mongrel_cluster.yml"
      
      run "mkdir -p #{shared_path}/log"
      run "mkdir -p #{shared_path}/pids"
      run "ln -nsfF #{shared_path}/log/ #{current_path}/log"
      run "ln -nsfF #{shared_path}/pids/ #{current_path}/tmp/pids"      
    end

    desc "Symlink shared configurations to current"
    task :localize, :roles => [:app] do
      %w[mongrel_cluster.yml database.yml].each do |f|
        run "ln -nsf #{shared_path}/config/#{f} #{current_path}/config/#{f}"
      end
    end    
  end  
end

# == DATABASE ==================================================================
# == BACKUP DB TASK

namespace :db do
  desc "Backup your Database to #{shared_path}/db_backups"
  task :backup, :roles => :db, :only => {:primary => true} do
    set :db_user, Capistrano::CLI.ui.ask("Database user: ")
    set :db_pass, Capistrano::CLI.password_prompt("Database password: ")
    now = Time.now
    run "mkdir -p #{shared_path}/backup"
    backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
    set :backup_file, "#{shared_path}/backup/#{application}-snapshot-#{backup_time}.sql"
    run "mysqldump --add-drop-table -u #{db_user} -p #{db_pass} #{application}_#{application_prefix}_production --opt | bzip2 -c > #{backup_file}.bz2"
  end
end

#== DEPLOYMENT
#=====================================================================

#before "deploy:migrate", "db:backup"

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:setup", "init:config:database"
after "deploy:setup", "init:config:mongrel"
after "deploy:symlink", "init:config:localize"
