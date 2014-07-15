class AddImageToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :image, :string
  end
end
