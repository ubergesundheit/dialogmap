# # create folders..
# directory File.join(node["users"]["apps_dir"], node["app"]["appname"], "shared", "config") do
#   #mode "0775"
#   owner node["users"]["apps_user"]
#   group node["users"]["apps_user"]
#   action :create
#   recursive true
# end

# directory File.join(node["users"]["apps_dir"], node["app"]["appname"], "shared", "config", "initializers") do
#   #mode "0775"
#   owner node["users"]["apps_user"]
#   group node["users"]["apps_user"]
#   action :create
#   recursive true
# end


# # create database.yml for symlinking to rails app
# template(File.join(node["users"]["apps_dir"], node["app"]["appname"], "shared", "config", "database.yml")) do
#   source 'database.yml.erb'
#   owner node["users"]["apps_user"]
#   group node["users"]["apps_user"]
#   variables(
#     database: node["mysql"]["database"]["database_name"],
#     username: node["mysql"]["database"]["username"],
#     password: node["mysql"]["database"]["password"]
#   )
# end

# # create secret_token.rb for symlinking to rails app
# template(File.join(node["users"]["apps_dir"], node["app"]["appname"], "shared", "config", "initializers", "secret_token.rb")) do
#   source 'secret_token.rb.erb'
#   owner node["users"]["apps_user"]
#   group node["users"]["apps_user"]
#   variables(
#     secret: node["app"]["secret_token"]
#   )
#   action :create_if_missing
# end
