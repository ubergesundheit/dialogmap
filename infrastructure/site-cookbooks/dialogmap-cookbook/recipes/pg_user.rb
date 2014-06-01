include_recipe "database::postgresql"

node.set['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]


postgresql_connection_info = {
  :host => "localhost",
  :port => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}


postgresql_database node["postgresql"]["database"]["database_name"] do
  connection postgresql_connection_info
  template node["postgresql"]["database"]["template"] if node["postgresql"]["database"]["template"]
  encoding node["postgresql"]["database"]["encoding"] if node["postgresql"]["database"]["encoding"]
  collation node["postgresql"]["database"]["collation"] if node["postgresql"]["database"]["collation"]
  connection_limit node["postgresql"]["database"]["connection_limit"] if node["postgresql"]["database"]["connection_limit"]
  owner node["postgresql"]["database"]["owner"] if node["postgresql"]["database"]["owner"]
  action :create
end

postgresql_database_user node["postgresql"]["database"]["username"] do
  connection postgresql_connection_info
  action [:create, :grant]
  password(node["postgresql"]["database"]["password"]) if node["postgresql"]["database"]["password"]
  database_name(node["postgresql"]["database"]["database_name"]) if node["postgresql"]["database"]["database_name"]
  privileges(node["postgresql"]["database"]["privileges"]) if node["postgresql"]["database"]["privileges"]
end
