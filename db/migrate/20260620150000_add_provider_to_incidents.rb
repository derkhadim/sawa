class AddProviderToIncidents < ActiveRecord::Migration[7.0]
  def change
    add_reference :incidents, :provider, null: true, foreign_key: true
  end
end
