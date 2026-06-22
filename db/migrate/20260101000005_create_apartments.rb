class CreateApartments < ActiveRecord::Migration[7.0]
  def change
    create_table :apartments do |t|
      t.string  :number,      null: false
      t.integer :floor
      t.decimal :rent_amount, null: false, precision: 10, scale: 2
      t.string  :status,      null: false, default: 'free'
      # status: free, occupied

      t.references :building, null: false, foreign_key: true
      t.references :tenant,   foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :apartments, [:building_id, :number], unique: true
  end
end
