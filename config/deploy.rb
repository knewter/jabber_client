default_run_options[:pty] = true

set :application, "jabber_client"
set :repository,  "git://github.com/knewter/jabber_client.git"

set :deploy_to, "/home/deploy/#{application}"
set :user,   "deploy"
set :runner, "deploy"

set :scm, :git

role :app, "209.20.72.204"
role :web, "209.20.72.204"
role :db,  "209.20.72.204", :primary => true

namespace :deploy do
  task :restart do
    slicehost:apache_reload
  end
end

namespace :slicehost do
  desc "Configure VHost"
  task :config_vhost do
    vhost_config =<<-EOF
<VirtualHost *:8000>
  ServerName libertyalabama.com
  ServerAlias www.libertyalabama.com
  DocumentRoot #{deploy_to}/current/public
</VirtualHost>
    EOF
    put vhost_config, "src/vhost_config"
    sudo "mv src/vhost_config /etc/apache2/sites-available/#{application}"
    sudo "a2ensite #{application}"
  end
  
  desc "Reload Apache"
  task :apache_reload do
    sudo "/etc/init.d/apache2 reload"
  end

  desc "install required gems"
  task :install_required_gems do
    run "cd #{deploy_to}/current; rake gems:install"
  end

  desc "git pull"
  task :git_pull do
    run "cd #{deploy_to}/current; git pull origin master"
  end
end

desc "symlink database.yml"
task :symlink_database_yml do
  run "ln -s #{latest_release}/config/database.yml.production #{latest_release}/config/database.yml"
end

desc "update git submodules"
task :update_submodules do
  run "cd #{latest_release}; git submodule init; git submodule update;"
end

desc "Symlink secret files"
task :symlink_secret_files do
  %w(
    jabber_client_test_login.rb
    initializers/site_keys.rb
  ).each do |the_file|
    run "ln -s #{deploy_to}/shared/#{the_file} #{latest_release}/config/#{the_file}"
  end
end

desc "Start up drb server to host jabber connections"
task :start_jabber_drb do
  run "cd #{latest_release}/lib; ruby jabber_connection_server_daemon.rb"
end

desc "Start juggernaut"
task :start_juggernaut do
  run "cd #{latest_release}; juggernaut -c config/juggernaut.yml"
end

desc "Start backgroundrb"
task :start_backgroundrb do
  run "cd #{latest_release}; export RAILS_ENV=production; script/backgroundrb start"
end

after "deploy:finalize_update" do
  update_submodules
  symlink_database_yml
  symlink_secret_files
  start_jabber_drb
  start_juggernaut
  start_backgroundrb
end
