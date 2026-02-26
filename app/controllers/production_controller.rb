class ProductionController < ApplicationController
  def index
    @tasks = policy_scope(Task)
      .where(status: [:in_progress, :approved])
      .where("approved_start_at <= ? OR preliminary_start_at <= ?", Date.current, Date.current)
      .where.not(status: :completed)
      .includes(:assignees, :project)
      .order(:preliminary_start_at)

    @grouped_tasks = {}
    @tasks.each do |task|
      if task.assignees.any?
        task.assignees.each { |a| (@grouped_tasks[a.full_name] ||= []) << task }
      else
        (@grouped_tasks["Не назначен"] ||= []) << task
      end
    end
    @grouped_tasks = @grouped_tasks.sort.to_h
  end
end
