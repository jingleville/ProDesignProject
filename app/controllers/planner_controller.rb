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
      .where("plan_start_at <= ? AND plan_due_at >= ?", @date_range.last, @date_range.first)
      .includes(:project, :assignee)
      .order(:plan_start_at)
  end

  def calendar
    authorize Task, :index?
    @days_ahead = (params[:days] || 30).to_i.clamp(7, 90)
    @tasks_by_date = policy_scope(Task)
      .where(
        "plan_due_at BETWEEN ? AND ?",
        Date.current, Date.current + @days_ahead.days
      )
      .includes(:project, :assignee)
      .order(plan_due_at: :asc)
      .group_by { |t| t.effective_due_date&.to_date }
  end
end
