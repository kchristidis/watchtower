class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :name
      t.integer :sensor_module_id

      t.timestamps
    end
  end
end
