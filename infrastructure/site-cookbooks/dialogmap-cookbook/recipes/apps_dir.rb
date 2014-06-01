#
# Cookbook Name:: dialogmap-cookbook
# Recipe:: apps_dir
#
# Setup base dir for apps deployment.
#
# IMPORTANT: It assumes node["users"]["apps_user"] user already exists.
#

def user_exists?(username)
  !!Etc.getpwnam(username) rescue false
end

unless user_exists? node["users"]["apps_user"]
  include_recipe "dialogmap-cookbook::users"
end

directory node['users']['apps_dir'] do
  mode "2775"
  owner node["users"]["apps_user"]
  group node["users"]["apps_user"]
  action :create
  recursive true
end
