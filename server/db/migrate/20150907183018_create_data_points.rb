class CreateDataPoints < ActiveRecord::Migration
  def change
    create_table :data_points do |t|
      t.integer :sensor_id
      t.float :data
      t.datetime :timestamp

      t.timestamps
    end
  end
end
