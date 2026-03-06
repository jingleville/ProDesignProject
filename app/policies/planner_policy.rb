class PlannerPolicy < ApplicationPolicy
  def index?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "director", "admin", "production_head"
        scope.all
      when "project_manager", "sales_manager"
        scope.joins(:project).where(projects: { creator_id: user.id })
      when "executor"
        scope.where(assignee_id: user.id)
      else
        scope.none
      end
    end
  end
end
