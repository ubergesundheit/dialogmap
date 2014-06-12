class AddDeletedToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :deleted, :boolean
    add_column :contributions, :delete_reason, :string
  end
end
