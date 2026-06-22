class AddCountersToPublications < ActiveRecord::Migration[7.2]
  def change
    add_column :publications, :likes_count, :integer, default: 0, null: false
    add_column :publications, :comments_count, :integer, default: 0, null: false
  end
end
