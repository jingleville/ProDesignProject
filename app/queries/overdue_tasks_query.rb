class OverdueTasksQuery
  def self.overdue_start
    Task.where(status: :approved)
        .where("plan_start_at < ?", Date.current)
  end

  def self.overdue_deadline
    Task.where.not(status: %w[completed cancelled])
        .where("plan_due_at < ?", Date.current)
  end

  def self.all_overdue
    overdue_ids = (overdue_start.pluck(:id) + overdue_deadline.pluck(:id)).uniq
    Task.where(id: overdue_ids)
  end
end
