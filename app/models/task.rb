class Task < ApplicationRecord
  include Auditable

  enum :status, {
    draft: 0,
    awaiting_production_approval: 1,
    approved: 2,
    in_progress: 3,
    completed: 4,
    rejected: 5
  }

  STATUS_TRANSLATIONS = {
    "draft" => "Черновик",
    "awaiting_production_approval" => "На согласовании",
    "approved" => "Согласована",
    "in_progress" => "В работе",
    "completed" => "Завершена",
    "rejected" => "Отклонена"
  }.freeze

  belongs_to :project
  belongs_to :created_by, class_name: "User"
  belongs_to :assigned_by, class_name: "User", optional: true
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :parent_task, class_name: "Task", optional: true
  has_many :child_tasks, class_name: "Task", foreign_key: :parent_task_id, dependent: :nullify

  has_many :task_dependencies, dependent: :destroy
  has_many :dependencies, through: :task_dependencies, source: :depends_on_task
  has_many :inverse_task_dependencies, class_name: "TaskDependency", foreign_key: :depends_on_task_id, dependent: :destroy
  has_many :dependents, through: :inverse_task_dependencies, source: :task

  has_many :task_assignees, dependent: :destroy
  has_many :assignees, through: :task_assignees, source: :user

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy
  has_many :budget_items, dependent: :destroy

  validates :title, presence: true
  validate :no_circular_parent, if: -> { parent_task_id.present? }
  validate :parent_in_same_project, if: -> { parent_task_id.present? }

  after_update :check_project_completion, if: -> { saved_change_to_status? && completed? }

  def overdue?
    return false if completed?

    due_date = approved_due_at || preliminary_due_at
    due_date.present? && due_date < Date.current
  end

  def assigned_to?(user)
    assignees.include?(user)
  end

  def dependencies_completed?
    dependencies.all?(&:completed?)
  end

  def start_date
    approved_start_at || preliminary_start_at
  end

  def due_date
    approved_due_at || preliminary_due_at
  end

  private

  def check_project_completion
    project.check_completion!
  end

  def no_circular_parent
    visited = []
    current = parent_task_id
    while current.present?
      if current == id || visited.include?(current)
        errors.add(:parent_task, "создаёт циклическую зависимость")
        return
      end
      visited << current
      current = Task.where(id: current).pick(:parent_task_id)
    end
  end

  def parent_in_same_project
    if Task.where(id: parent_task_id).pick(:project_id) != project_id
      errors.add(:parent_task, "должна принадлежать тому же проекту")
    end
  end
end
