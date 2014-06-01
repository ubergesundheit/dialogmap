#
# Cookbook Name:: rails-cookbook
# Recipe:: postgresql
#
# Install Postgresql and create specified databases and users.
#

root_password = node["postgresql"]["db_root_password"]
if root_password
  Chef::Log.info %(Set node["postgresql"]["password"]["postgres"] attributes to node["postgresql"]["db_root_password"])
  node.set["postgresql"]["password"]["postgres"] = root_password
end

include_recipe "postgresql::client"
include_recipe "postgresql::server"
