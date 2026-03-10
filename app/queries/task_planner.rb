class TaskPlanner
  def initialize(date:)
    @date = date
  end

  def day_plan(executor)
    base_scope(executor).where(plan_start_at: ..@date.end_of_day)
  end

  def week_plan(executor)
    end_of_week = @date.end_of_week
    base_scope(executor).where(plan_start_at: ..end_of_week)
  end

  def production_overview
    Task.where(status: %w[approved in_progress pending_confirmation])
        .where.not(assignee_id: nil)
        .group_by(&:assignee_id)
  end

  private

  def base_scope(executor)
    Task.where(assignee: executor)
        .where(status: %w[approved in_progress])
  end
end
