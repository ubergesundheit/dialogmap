default["app"]["appname"] = ""
default["app"]["hostname"] = "localhost"
require 'securerandom'
default["app"]["devise_secret_key"] = SecureRandom.hex(64)
default["app"]["secret_key_base"] = SecureRandom.hex(64)
default["users"]["deploy_keys"] = []
default["users"]["apps_dir"] = "/home/apps"

default["users"]["deploy_user"] = "deploy"
default["users"]["apps_user"] = "apps"

default["postgresql"]["database"]["username"] = "dialog_map"
default["postgresql"]["database"]["database_name"] = "dialog_map_production"

default["ruby"]["version"] = "2.1.2"


default['nginx']['source']['modules'] = %w[
                                          nginx::http_ssl_module
                                          nginx::http_gzip_static_module
                                          nginx::passenger
                                          ]
