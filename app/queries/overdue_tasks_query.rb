class OverdueTasksQuery
  def self.overdue_start
    Task.where(status: :approved)
        .where("approved_start_at < ?", Date.current)
  end

  def self.overdue_deadline
    today = Date.current
    Task.where.not(status: %w[completed cancelled])
        .where(
          "CASE WHEN approved_due_at IS NOT NULL THEN approved_due_at < ? ELSE plan_due_at < ? END",
          today, today
        )
  end

  def self.all_overdue
    overdue_ids = (overdue_start.pluck(:id) + overdue_deadline.pluck(:id)).uniq
    Task.where(id: overdue_ids)
  end
end
