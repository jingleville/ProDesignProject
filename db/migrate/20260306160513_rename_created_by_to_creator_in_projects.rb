class RenameCreatedByToCreatorInProjects < ActiveRecord::Migration[7.2]
  def change
    rename_column :projects, :created_by_id, :creator_id
  end
end
