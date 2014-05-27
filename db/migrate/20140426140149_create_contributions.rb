class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.string :title
      t.text :description
      t.references :user
      t.integer :parent_id

      t.timestamps
    end
  end
end
