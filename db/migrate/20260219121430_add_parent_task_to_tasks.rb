class AddParentTaskToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :parent_task_id, :integer, null: true
    add_foreign_key :tasks, :tasks, column: :parent_task_id
    add_index :tasks, :parent_task_id
  end
end
