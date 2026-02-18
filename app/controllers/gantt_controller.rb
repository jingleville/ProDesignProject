class GanttController < ApplicationController
  def index
    @projects = policy_scope(Project).where(status: [ :active, :draft ]).includes(:tasks)
  end
end
