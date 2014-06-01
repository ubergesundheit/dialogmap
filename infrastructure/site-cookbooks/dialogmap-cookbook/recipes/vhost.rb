execute "nxdissite default" do
end

app_dir = ::File.join(node["users"]["apps_dir"], node["app"]["appname"], 'current')

template( File.join(node["nginx"]["dir"], "sites-available", node["app"]["appname"]) ) do
  source "nginx_vhost.conf.erb"
  cookbook "dialogmap-cookbook"
  mode "0644"
  owner "root"
  group "root"
  variables(
    :root_path => ::File.join(app_dir, 'public'),
    :log_dir => node["nginx"]["log_dir"],
    :appname => node["app"]["appname"],
    :hostname => node["app"]["hostname"],
    :ssl_key => node["ssl_key"],
    :ssl_cert => node["ssl_cert"]
  )
  notifies :reload, "service[nginx]"
end

nginx_site node["app"]["appname"] do
  notifies :reload, "service[nginx]"
end
