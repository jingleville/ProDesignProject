class Stage < ApplicationRecord
  belongs_to :project
  has_many :tasks, dependent: :nullify

  validates :name, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :position, uniqueness: { scope: :project_id }

  def completion_percentage
    return 0 if tasks.empty?

    completed_count = tasks.count { |t| t.completed? }
    (completed_count.to_f / tasks.count * 100).round
  end
end
