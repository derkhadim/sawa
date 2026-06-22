class CreateAgencies < ActiveRecord::Migration[7.0]
  def change
    create_table :agencies do |t|
      t.string :name,       null: false
      t.string :address
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
