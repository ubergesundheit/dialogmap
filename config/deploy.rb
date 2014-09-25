# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'dialog_map'
set :repo_url, 'git@github.com:ubergesundheit/dialogmap.git'

set :branch, 'nachhaltigkeitslandkarte'

set :deploy_to, '/home/apps/dialog-map'

set :bundle_flags, "--deployment"
set :bundle_without, "test development deploy"

set :rbenv_type, :system
set :rbenv_ruby, '2.1.3'
set :rbenv_custom_path, '/opt/rbenv'

set :linked_files, %w{.rbenv-vars}
set :linked_dirs, %w{public/static_images}
# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []


# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  before :starting, :chown_apps_dir_to_deploy
  after :log_revision, :chown_apps_dir_to_apps

  before :migrate, :dbuser_to_superuser
  after :migrate, :dbuser_from_superuser

end
