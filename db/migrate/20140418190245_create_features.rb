class CreateFeatures < ActiveRecord::Migration
  def change
    #enable_extension "hstore"
    create_table :features do |t|
      t.belongs_to :contribution

      t.geometry :geom, :geographic => true, :srid=> 4326, :null => false

      t.hstore :properties

      t.timestamps

      t.index :geom, :spatial => true
    end
  end
end
