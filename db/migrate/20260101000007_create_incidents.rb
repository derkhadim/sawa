class CreateIncidents < ActiveRecord::Migration[7.0]
  def change
    create_table :incidents do |t|
      t.string  :title,       null: false
      t.text    :description, null: false
      t.string  :status,      null: false, default: 'open'
      # status: open, in_progress, resolved

      t.references :apartment, null: false, foreign_key: true
      t.references :tenant,    null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
