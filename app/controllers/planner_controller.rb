class PlannerController < ApplicationController
  def index
    @mode = params[:mode] || "week"
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current

    if @mode == "day"
      @date_range = @date..@date
    else
      @date_range = @date.beginning_of_week..@date.end_of_week
    end

    @tasks = policy_scope(Planner).includes(:created_by, :tasks)
    @tasks = Task.where("(approved_start_at <= ? AND approved_due_at >= ?) OR (preliminary_start_at <= ? AND preliminary_due_at >= ?)",
                            @date_range.last, @date_range.first, @date_range.last, @date_range.first)
                     .includes(:project)
                     .order(:preliminary_start_at)
  end
end
