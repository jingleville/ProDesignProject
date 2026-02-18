class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :created_by_id, null: false
      t.integer :assigned_by_id
      t.integer :assignee_id
      t.date :preliminary_start_at
      t.date :preliminary_due_at
      t.date :approved_start_at
      t.date :approved_due_at
      t.integer :status, null: false, default: 0
      t.datetime :completed_at
      t.integer :approved_by_id

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :assignee_id
    add_index :tasks, :created_by_id
  end
end
