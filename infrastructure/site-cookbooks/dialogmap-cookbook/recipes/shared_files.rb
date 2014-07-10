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
    database_password: node["postgresql"]["database"]["password"],
    oauth_facebook_key: node["app"]["oauth"]["facebook"]["key"],
    oauth_facebook_secret: node["app"]["oauth"]["facebook"]["secret"],
    oauth_twitter_key: node["app"]["oauth"]["twitter"]["key"],
    oauth_twitter_secret: node["app"]["oauth"]["twitter"]["secret"],
    oauth_google_key: node["app"]["oauth"]["google"]["key"],
    oauth_google_secret: node["app"]["oauth"]["google"]["secret"],
    hostname: node["app"]["hostname"],
    smtp_host: node["app"]["email"]["smtp"]["host"],
    smtp_port: node["app"]["email"]["smtp"]["port"],
    smtp_user: node["app"]["email"]["smtp"]["user"],
    smtp_password: node["app"]["email"]["smtp"]["password"],
    email_from: node["app"]["email"]["email_from"]
  )
  action :create_if_missing
end
