class AddPropertiesToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :properties, :hstore
  end
end
