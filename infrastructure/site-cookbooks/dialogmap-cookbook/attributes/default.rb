default["app"]["appname"] = ""
default["app"]["hostname"] = "localhost"
require 'securerandom'
default["app"]["secret_token"] = SecureRandom.hex(64)
default["users"]["deploy_keys"] = []
default["users"]["apps_dir"] = "/home/apps"

default["users"]["deploy_user"] = "deploy"
default["users"]["apps_user"] = "apps"


default["ruby"]["version"] = "2.1.2"


default['nginx']['source']['modules'] = %w[
                                          nginx::http_ssl_module
                                          nginx::http_gzip_static_module
                                          nginx::passenger
                                          ]
