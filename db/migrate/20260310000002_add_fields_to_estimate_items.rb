class AddFieldsToEstimateItems < ActiveRecord::Migration[7.2]
  def change
    add_column :estimate_items, :unit, :string
    add_column :estimate_items, :note, :text
    add_column :estimate_items, :position, :integer
  end
end
