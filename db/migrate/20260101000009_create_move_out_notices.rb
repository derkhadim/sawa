class CreateMoveOutNotices < ActiveRecord::Migration[7.0]
  def change
    create_table :move_out_notices do |t|
      t.date :move_out_date, null: false

      t.references :apartment, null: false, foreign_key: true
      t.references :tenant,    null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
