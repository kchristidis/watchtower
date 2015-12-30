class CreateDashboards < ActiveRecord::Migration
  def change
    create_table :dashboards do |t|
      t.integer :user_id
      t.text :config
      t.string :name

      t.timestamps
    end
  end
end
