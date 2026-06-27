class MakeEmailNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :email, true
    remove_index :users, :email
  end
end
