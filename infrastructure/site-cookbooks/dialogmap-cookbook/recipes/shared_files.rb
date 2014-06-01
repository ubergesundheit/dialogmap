# create folders..
directory File.join(node["users"]["apps_dir"], node["app"]["appname"], "shared") do
  #mode "0775"
  owner node["users"]["apps_user"]
  group node["users"]["apps_user"]
  action :create
  recursive true
end

# create .rbenv-vars for symlinking to rails app
template(File.join(node["users"]["apps_dir"], node["app"]["appname"], "shared", ".rbenv-vars")) do
  source 'rbenv-vars.erb'
  owner node["users"]["apps_user"]
  group node["users"]["apps_user"]
  variables(
    devise_secret_key: node["app"]["devise_secret_key"],
    secret_key_base: node["app"]["secret_key_base"],
    database_password: node["postgresql"]["database"]["password"]
  )
  action :create_if_missing
end
