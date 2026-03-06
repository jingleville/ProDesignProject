class CreateEstimateItems < ActiveRecord::Migration[7.2]
  def change
    drop_table :estimate_items, if_exists: true

    create_table :estimate_items do |t|
      t.string :name, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
