desc "Chown the apps dir to apps user"
task :chown_apps_dir_to_apps do
  on roles(:all) do
    sudo :chown, "-R apps:apps #{deploy_to}"
  end
end

desc "Chown the apps dir to deploy user"
task :chown_apps_dir_to_deploy do
  on roles(:all) do
    if test "[ -d #{deploy_to} ]"
      sudo :chown, "-R deploy:deploy #{deploy_to}"
    end
  end
end
