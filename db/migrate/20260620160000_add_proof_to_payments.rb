class AddProofToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :proof, :string
  end
end
