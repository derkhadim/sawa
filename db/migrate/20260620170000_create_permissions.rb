class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions do |t|
      t.string :resource, null: false
      t.string :action, null: false
      t.string :description
      t.timestamps
      t.index [:resource, :action], unique: true
    end
  end
end
