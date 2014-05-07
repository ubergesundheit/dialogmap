class CreateReferences < ActiveRecord::Migration
  def change
    create_table :references do |t|
      t.belongs_to :contribution

      t.string :type
      t.string :title
      t.integer :ref_id
      t.string :url

      t.timestamps
    end
  end
end
