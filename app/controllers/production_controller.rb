class ProductionController < ApplicationController
  def index
    @tasks = policy_scope(Task)
      .where(status: [:approved, :in_progress, :pending_confirmation])
      .includes(:assignee, :project)
      .order(:plan_start_at)

    @grouped_tasks = {}
    @tasks.each do |task|
      key = task.assignee&.full_name || "Не назначен"
      (@grouped_tasks[key] ||= []) << task
    end
    @grouped_tasks = @grouped_tasks.sort.to_h
  end
end
