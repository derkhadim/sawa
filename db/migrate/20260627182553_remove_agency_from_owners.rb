class RemoveAgencyFromOwners < ActiveRecord::Migration[7.2]
  def change
    remove_reference :owners, :agency, null: false, foreign_key: true
  end
end
