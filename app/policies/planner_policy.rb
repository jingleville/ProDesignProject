class PlannerPolicy < ApplicationPolicy
  def index?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "director", "admin", "production_manager"
        scope.all
      when "project_manager", "sales_manager"
        scope.joins(:project).where(projects: { created_by_id: user.id })
      when "worker"
        scope.where(assignee_id: user.id)
      else
        scope.none
      end
    end
  end
end
