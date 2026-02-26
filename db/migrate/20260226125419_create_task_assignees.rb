class CreateTaskAssignees < ActiveRecord::Migration[7.2]
  def up
    create_table :task_assignees do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :task_assignees, [:task_id, :user_id], unique: true

    # Перенести существующих исполнителей в join-таблицу
    execute <<~SQL
      INSERT INTO task_assignees (task_id, user_id, created_at, updated_at)
      SELECT id, assignee_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM tasks
      WHERE assignee_id IS NOT NULL
    SQL
  end

  def down
    drop_table :task_assignees
  end
end
