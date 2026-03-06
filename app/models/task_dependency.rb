class TaskDependency < ApplicationRecord
  enum :dependency_type, {
    finish_to_start: 0,
    start_to_start: 1,
    finish_to_finish: 2,
    start_to_finish: 3
  }

  belongs_to :task
  belongs_to :depends_on_task, class_name: "Task"

  validates :dependency_type, presence: true
  validates :depends_on_task_id, uniqueness: { scope: :task_id }
  validate :no_self_dependency
  validate :no_circular_dependency

  private

  def no_self_dependency
    errors.add(:depends_on_task_id, "task cannot depend on itself") if task_id == depends_on_task_id
  end

  def no_circular_dependency
    return if depends_on_task_id.blank? || task_id.blank?

    visited = Set.new
    queue = [ task_id ]

    while queue.any?
      current = queue.shift
      next if visited.include?(current)
      visited << current

      if current == depends_on_task_id && current != task_id
        errors.add(:base, "circular dependency detected")
        return
      end

      TaskDependency.where(depends_on_task_id: current).pluck(:task_id).each do |dep_id|
        queue << dep_id
      end
    end
  end
end
