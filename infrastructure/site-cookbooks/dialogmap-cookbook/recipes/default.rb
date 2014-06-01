#
# Cookbook Name:: dialogmap-cookbook
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Update apt-get packages
include_recipe 'apt'

# install git and curl
include_recipe 'curl'
include_recipe 'git'

# create users
include_recipe 'dialogmap-cookbook::users'
# create directories for users
include_recipe 'dialogmap-cookbook::apps_dir'

# include_recipe 'dialogmap-cookbook::shared_files'

include_recipe 'dialogmap-cookbook::postgresql'
include_recipe 'dialogmap-cookbook::pg_user'

# this does not work :(
# package 'postgresql-9.3-postgis'
bash "install_postgis" do
  user "root"
  code <<-EOH
  apt-get install -y postgresql-9.3-postgis
  EOH
end

include_recipe 'dialogmap-cookbook::ruby'

# set passenger and ruby paths for the nginx::passenger recipe
node.default["nginx"]["passenger"]["ruby"] = node[:rbenv][:root] + "/shims/ruby"
node.default["nginx"]["passenger"]["root"] = node[:rbenv][:root] + "/versions/" + node[:ruby][:version] + "/lib/ruby/gems/2.1.0/gems/passenger-"  + node[:nginx][:passenger][:version]
include_recipe 'nginx::source'

# disable default vhost and create new vhost
include_recipe 'dialogmap-cookbook::vhost'

include_recipe 'nodejs::install_from_package'

swap_file '/swap' do
  size     4096  # MBs
  persist  true
  action   :create
end
