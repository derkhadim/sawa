class CreatePublications < ActiveRecord::Migration[7.0]
  def change
    create_table :publications do |t|
      t.text :content, null: false

      t.references :building, null: false, foreign_key: true
      t.references :tenant,   null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
