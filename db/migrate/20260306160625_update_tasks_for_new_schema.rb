class UpdateTasksForNewSchema < ActiveRecord::Migration[7.2]
  def change
    add_reference :tasks, :stage, null: true, foreign_key: true
    add_column :tasks, :plan_start_at, :date
    add_column :tasks, :plan_due_at, :date
    add_column :tasks, :actual_start_at, :datetime
    add_column :tasks, :actual_due_at, :datetime
    add_column :tasks, :approved_at, :datetime
  end
end
