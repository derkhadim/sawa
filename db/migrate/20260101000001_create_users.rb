class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email,           null: false
      t.string :phone,           null: false
      t.string :password_digest, null: false
      t.string :first_name,      null: false
      t.string :last_name,       null: false
      t.string :role,            null: false, default: 'tenant'
      # role: super_admin, agent, tenant, owner

      t.references :agency, foreign_key: true
      t.references :building, foreign_key: true

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
  end
end
