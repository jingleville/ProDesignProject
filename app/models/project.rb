class Project < ApplicationRecord
  include Auditable

  enum :status, {
    draft: 0,
    active: 1,
    completed: 2,
    archived: 3
  }

  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  has_many :stages, -> { order(:position) }, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :estimate_items, dependent: :destroy

  validates :name, presence: true

  def check_completion!
    return unless active?

    active_tasks = tasks.where.not(status: :cancelled)
    return if active_tasks.empty?

    update!(status: :completed) if active_tasks.all?(&:completed?)
  end
end
