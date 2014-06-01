# Install and setup Ruby environment
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby node["ruby"]["version"] do
  global(node["ruby"]["version"])
end
rbenv_gem "bundler" do
  ruby_version node["ruby"]["version"]
end
rbenv_gem "passenger" do
  ruby_version node["ruby"]["version"]
  version node["nginx"]["passenger"]["version"]
end
# install pg gem
rbenv_gem "pg" do
  ruby_version node["ruby"]["version"]
end

# set rbenv for all users
directory "/etc/profile.d" do
  owner "root"
  mode "0755"
end

template "/etc/profile.d/rbenv.sh" do
  source "rbenv.sh.erb"
  owner "root"
  mode "0755"
end
