class ProductionController < ApplicationController
  # skip_after_action :verify_policy_scoped

  def index
    @tasks = Task.where(status: [ :in_progress, :approved ])
                 .where("approved_start_at <= ? OR preliminary_start_at <= ?", Date.current, Date.current)
                 .where.not(status: :completed)
                 .includes(:assignee, :project)
                 .order(:assignee_id, :preliminary_start_at)

    @grouped_tasks = @tasks.group_by { |t| t.assignee&.full_name || "Unassigned" }
  end
end
