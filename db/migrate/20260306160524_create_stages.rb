class CreateStages < ActiveRecord::Migration[7.2]
  def change
    create_table :stages do |t|
      t.string :name
      t.integer :position
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
