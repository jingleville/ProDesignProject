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
      .where("(approved_start_at <= ? AND approved_due_at >= ?) OR (preliminary_start_at <= ? AND preliminary_due_at >= ?)",
             @date_range.last, @date_range.first, @date_range.last, @date_range.first)
      .includes(:project)
      .order(:preliminary_start_at)
  end

  def calendar
    authorize Task, :index?
    @days_ahead = (params[:days] || 30).to_i.clamp(7, 90)
    base_tasks = policy_scope(Task)
    @tasks_by_date = base_tasks
      .where("COALESCE(approved_due_at, preliminary_due_at) BETWEEN ? AND ?",
             Date.current, Date.current + @days_ahead.days)
      .includes(:project, :assignees)
      .order(Arel.sql("COALESCE(approved_due_at, preliminary_due_at) ASC"))
      .group_by(&:due_date)
  end
end
