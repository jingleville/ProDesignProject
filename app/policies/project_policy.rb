class ProjectPolicy < ApplicationPolicy
  def index?
    !user.executor?
  end

  def show?
    !user.executor?
  end

  def create?
    user.sales_manager? || user.project_manager? || user.is_admin?
  end

  def update?
    user.is_admin? ||
      (record.creator_id == user.id && (user.project_manager? || user.sales_manager?))
  end

  def destroy?
    user.is_admin?
  end

  def archive?
    user.is_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "production_head", "director", "admin"
        scope.all
      when "project_manager", "sales_manager"
        scope.where(creator: user).where.not(status: :archived)
      when "executor"
        scope.joins(:tasks).where(tasks: { assignee_id: user.id }).distinct
      else
        scope.none
      end
    end
  end
end
