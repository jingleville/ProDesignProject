class ChangeApprovedDatesInTasksToDatetime < ActiveRecord::Migration[7.2]
  def up
    change_column :tasks, :approved_start_at, :datetime
    change_column :tasks, :approved_due_at, :datetime
  end

  def down
    change_column :tasks, :approved_start_at, :date
    change_column :tasks, :approved_due_at, :date
  end
end
