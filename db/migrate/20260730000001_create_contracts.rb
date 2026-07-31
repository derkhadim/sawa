class CreateContracts < ActiveRecord::Migration[7.2]
  def change
    create_table :contracts do |t|
      t.references :apartment, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: { to_table: :users }
      t.references :agency, null: false, foreign_key: true

      t.string :contract_number, null: false
      t.text :content
      t.decimal :rent_amount, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'pending_tenant'

      t.text :tenant_signature
      t.datetime :tenant_signed_at

      t.date :start_date
      t.integer :duration_months

      t.timestamps
    end

    add_index :contracts, :contract_number, unique: true
    add_index :contracts, :status
  end
end
