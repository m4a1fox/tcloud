require 'bundler/capistrano' # Bundler
require 'capistrano_colors'

set :stages, %w(qa qa-frontend dev dev-frontend backend frontend)
set :default_stage, "dev"
require 'capistrano/ext/multistage'

set :default_environment, {
  'PATH' => "/opt/ruby-1.9.3-p327/bin:$PATH"
}

set :deploy_via, :remote_cache
set :keep_releases, 5

set :scm, :git
set :repository,  "git@github.com:TribecaDigital/TCloud.git"
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :use_sudo, false

set(:deploy_to){ "/srv/#{application}" }

set :normalize_asset_timestamps, false

before 'deploy:migrate', 'deploy:custom_symlinks'
after 'deploy:create_symlink', 'deploy:migrate'
after "deploy:restart", "resque:restart"
after "deploy:update", "deploy:cleanup"

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo /etc/init.d/thin restart"
  end

  task :custom_symlinks do
    run "ln -s #{deploy_to}/shared/config/application.yml #{current_release}/config/application.yml"
    run "ln -fs #{deploy_to}/shared/config/server_templates.yml #{current_release}/aws/server_templates.yml"
    run "ln -s #{deploy_to}/shared/config/.chef/ #{current_release}/config/.chef"
    run "ln -s #{deploy_to}/shared/uploads/servers #{current_release}/"
  end

end

namespace :resque do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo /etc/init.d/resque-pool-tcloud restart"
    run "sudo /etc/init.d/resque-scheduler-tcloud restart"
  end
end
