class CreateChangeLogs < ActiveRecord::Migration[7.2]
  def change
    drop_table :change_logs, if_exists: true

    create_table :change_logs do |t|
      t.string :entity_type, null: false
      t.integer :entity_id, null: false
      t.string :field_name, null: false
      t.text :old_value
      t.text :new_value
      t.references :changed_by, null: false, foreign_key: { to_table: :users }
      t.datetime :changed_at, null: false

      t.timestamps
    end

    add_index :change_logs, [:entity_type, :entity_id]
  end
end
