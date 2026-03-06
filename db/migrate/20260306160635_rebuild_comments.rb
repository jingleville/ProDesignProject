class RebuildComments < ActiveRecord::Migration[7.2]
  def up
    # Remove polymorphic columns, add task_id and mentions
    add_reference :comments, :task, null: true, foreign_key: true
    add_column :comments, :mentions, :text, default: "[]"
  end

  def down
    remove_reference :comments, :task
    remove_column :comments, :mentions
  end
end
