class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.decimal :amount,      null: false, precision: 10, scale: 2
      t.date    :paid_at
      t.date    :due_date,    null: false
      t.string  :status,      null: false, default: 'pending'
      t.integer :month,       null: false
      t.integer :year,        null: false
      t.string  :reference

      t.references :apartment, null: false, foreign_key: true
      t.references :tenant,    null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :payments, [:apartment_id, :month, :year], unique: true
  end
end
