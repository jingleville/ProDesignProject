class PlannerController < ApplicationController
  def index
    authorize Task, :index?
    @mode = params[:mode] || "week"
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current

    if @mode == "day"
      @date_range = @date..@date
    else
      @date_range = @date.beginning_of_week..@date.end_of_week
    end

    @tasks = policy_scope(Task)
      .where(
        "(approved_start_at <= ? AND approved_due_at >= ?) OR (plan_start_at <= ? AND plan_due_at >= ?)",
        @date_range.last, @date_range.first, @date_range.last, @date_range.first
      )
      .includes(:project, :assignee)
      .order(:plan_start_at)
  end

  def calendar
    authorize Task, :index?
    @days_ahead = (params[:days] || 30).to_i.clamp(7, 90)
    @tasks_by_date = policy_scope(Task)
      .where(
        "COALESCE(approved_due_at, plan_due_at) BETWEEN ? AND ?",
        Date.current, Date.current + @days_ahead.days
      )
      .includes(:project, :assignee)
      .order(Arel.sql("COALESCE(approved_due_at, plan_due_at) ASC"))
      .group_by { |t| t.effective_due_date&.to_date }
  end
end
