class AddDatesToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :start_date, :timestamp
    add_column :contributions, :end_date, :timestamp
  end
end
