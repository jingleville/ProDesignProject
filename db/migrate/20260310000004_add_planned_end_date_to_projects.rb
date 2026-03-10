class AddPlannedEndDateToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :planned_end_date, :date
  end
end
