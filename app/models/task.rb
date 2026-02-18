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

  has_many :task_dependencies, dependent: :destroy
  has_many :dependencies, through: :task_dependencies, source: :depends_on_task
  has_many :inverse_task_dependencies, class_name: "TaskDependency", foreign_key: :depends_on_task_id, dependent: :destroy
  has_many :dependents, through: :inverse_task_dependencies, source: :task

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy

  validates :title, presence: true

  after_update :check_project_completion, if: -> { saved_change_to_status? && completed? }

  def overdue?
    return false if completed?

    due_date = approved_due_at || preliminary_due_at
    due_date.present? && due_date < Date.current
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
end
