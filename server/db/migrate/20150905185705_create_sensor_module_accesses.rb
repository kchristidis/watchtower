class CreateSensorModuleAccesses < ActiveRecord::Migration
  def change
    create_table :sensor_module_accesses do |t|
      t.integer :sensor_module_id
      t.integer :user_id

      t.timestamps
    end
  end
end
