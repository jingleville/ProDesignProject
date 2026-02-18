class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :created_by_id, null: false

      t.timestamps
    end

    add_index :projects, :status
    add_index :projects, :created_by_id
  end
end
