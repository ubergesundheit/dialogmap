class AddFavoriteToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :favorites, :integer, array: true, default: []
    add_index :contributions, :favorites, using: 'gin'
  end
end
