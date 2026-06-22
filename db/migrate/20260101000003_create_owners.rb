class CreateOwners < ActiveRecord::Migration[7.0]
  def change
    create_table :owners do |t|
      t.string :first_name, null: false
      t.string :last_name,  null: false
      t.string :phone
      t.string :email

      t.references :agency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
