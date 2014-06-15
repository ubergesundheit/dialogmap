class AddDeletedToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :deleted, :boolean, null: false, default: false
    add_column :contributions, :delete_reason, :string
  end
end
