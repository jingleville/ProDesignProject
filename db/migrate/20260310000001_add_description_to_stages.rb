class AddDescriptionToStages < ActiveRecord::Migration[7.2]
  def change
    add_column :stages, :description, :text
  end
end
