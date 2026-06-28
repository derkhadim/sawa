class AddOwnerIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :owner, null: true, foreign_key: false

    reversible do |dir|
      dir.up do
        User.where.not(email: nil).find_each do |user|
          owner = Owner.find_by(email: user.email)
          user.update_column(:owner_id, owner.id) if owner
        end
      end
    end
  end
end
