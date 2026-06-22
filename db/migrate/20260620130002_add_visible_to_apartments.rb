class AddVisibleToApartments < ActiveRecord::Migration[7.0]
  def change
    add_column :apartments, :visible, :boolean, default: false, null: false
  end
end
