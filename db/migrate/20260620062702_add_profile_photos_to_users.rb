class AddProfilePhotosToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :profile_photo, :string
    add_column :users, :cover_photo, :string
  end
end
