class AddPaymentMethodToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :payment_method, :string, default: nil
  end
end
