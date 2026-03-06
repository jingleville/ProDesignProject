class AddDataToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :data, :text, default: "{}"
  end
end
