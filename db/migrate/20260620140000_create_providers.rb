class CreateProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :providers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone, null: false
      t.string :trade, null: false
      t.references :agency, null: false, foreign_key: true
      t.timestamps
    end
  end
end
