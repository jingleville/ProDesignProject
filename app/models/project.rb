class Project < ApplicationRecord
  include Auditable

  enum :status, {
    draft: 0,
    active: 1,
    completed: 2,
    archived: 3
  }

  STATUS_TRANSLATIONS = {
    "draft" => "Черновик",
    "active" => "Активный",
    "completed" => "Завершён",
    "archived" => "В архиве"
  }.freeze

  belongs_to :created_by, class_name: "User"
  has_many :tasks, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy

  validates :name, presence: true

  def check_completion!
    return unless active?
    return if tasks.empty?

    update!(status: :completed) if tasks.all?(&:completed?)
  end
end
