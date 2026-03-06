class Task < ApplicationRecord
  include Auditable

  enum :status, {
    draft: 0,
    awaiting_approval: 1,
    approved: 2,
    in_progress: 3,
    pending_confirmation: 4,
    completed: 5,
    cancelled: 6
  }

  belongs_to :project
  belongs_to :created_by, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :stage, optional: true

  has_many :task_dependencies, dependent: :destroy
  has_many :dependencies, through: :task_dependencies, source: :depends_on_task
  has_many :comments, dependent: :destroy
  has_many :change_logs, foreign_key: :entity_id, primary_key: :id

  validates :title, presence: true

  after_update :check_project_completion, if: -> { saved_change_to_status? && completed? }

  def overdue?
    return false if completed? || cancelled?

    due = approved_due_at || plan_due_at
    due.present? && due < Date.current
  end

  def effective_due_date
    approved_due_at || plan_due_at
  end

  def dependencies_completed?
    dependencies.all?(&:completed?)
  end

  private

  def check_project_completion
    project.check_completion!
  end
end
