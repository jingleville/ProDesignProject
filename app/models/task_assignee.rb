class TaskAssignee < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :user_id, uniqueness: { scope: :task_id, message: "уже является исполнителем этой задачи" }
end
