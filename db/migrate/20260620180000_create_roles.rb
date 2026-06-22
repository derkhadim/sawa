class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.references :agency, null: true, foreign_key: true
      t.string :description
      t.timestamps
      t.index [:name, :agency_id], unique: true
    end
  end
end
