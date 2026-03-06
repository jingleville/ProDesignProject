class AddDependencyTypeToTaskDependencies < ActiveRecord::Migration[7.2]
  def change
    add_column :task_dependencies, :dependency_type, :integer, default: 0, null: false
  end
end
