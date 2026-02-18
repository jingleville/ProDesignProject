class CreateTaskDependencies < ActiveRecord::Migration[7.2]
  def change
    create_table :task_dependencies do |t|
      t.references :task, null: false, foreign_key: true
      t.integer :depends_on_task_id, null: false

      t.timestamps
    end

    add_index :task_dependencies, :depends_on_task_id
    add_index :task_dependencies, [ :task_id, :depends_on_task_id ], unique: true
  end
end
