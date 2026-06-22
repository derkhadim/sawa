class AddPhotosToApartments < ActiveRecord::Migration[7.0]
  def change
    add_column :apartments, :photos, :text
  end
end
