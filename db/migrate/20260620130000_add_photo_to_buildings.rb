class AddPhotoToBuildings < ActiveRecord::Migration[7.0]
  def change
    add_column :buildings, :photo, :string
  end
end
