class CreateSensorAccesses < ActiveRecord::Migration
  def change
    create_table :sensor_accesses do |t|
      t.integer :sensor_id
      t.integer :sensor_module_id
      t.integer :user_id

      t.timestamps
    end
  end
end
