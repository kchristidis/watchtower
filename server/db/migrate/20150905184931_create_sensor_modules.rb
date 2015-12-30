class CreateSensorModules < ActiveRecord::Migration
  def change
    create_table :sensor_modules do |t|
      t.string :name
      t.string :location
      t.integer :user_id

      t.timestamps
    end
  end
end
