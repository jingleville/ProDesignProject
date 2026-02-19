class CreateBudgetItems < ActiveRecord::Migration[7.2]
  def change
    create_table :budget_items do |t|
      t.references :task, null: false, foreign_key: true
      t.string  :material, null: false
      t.string  :format
      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 0
      t.decimal :price,    precision: 10, scale: 2, null: false, default: 0
      t.timestamps
    end
  end
end
