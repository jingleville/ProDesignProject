class RemoveLegacyDateFieldsFromTasks < ActiveRecord::Migration[7.2]
  def change
    remove_column :tasks, :preliminary_start_at, :date
    remove_column :tasks, :preliminary_due_at, :date
    remove_column :tasks, :approved_start_at, :datetime
    remove_column :tasks, :approved_due_at, :datetime
    remove_column :tasks, :approved_at, :datetime
  end
end
