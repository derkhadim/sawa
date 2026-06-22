class CreateBuildings < ActiveRecord::Migration[7.0]
  def change
    create_table :buildings do |t|
      t.string :name,         null: false
      t.string :address,      null: false
      t.string :neighborhood
      t.string :commune
      t.decimal :latitude,    precision: 10, scale: 7
      t.decimal :longitude,   precision: 10, scale: 7

      t.references :owner,  null: false, foreign_key: true
      t.references :agency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
