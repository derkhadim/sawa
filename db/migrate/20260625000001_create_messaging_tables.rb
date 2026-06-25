class CreateMessagingTables < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.timestamps
    end

    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamp :last_read_at
      t.timestamps
    end
    add_index :conversation_participants, [:conversation_id, :user_id], unique: true

    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.timestamp :read_at
      t.timestamps
    end
  end
end
