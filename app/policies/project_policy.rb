class ProjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.project_manager? || user.sales_manager? || user.admin?
  end

  def update?
    user.admin? ||
      (record.created_by_id == user.id && (user.project_manager? || user.sales_manager?))
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "production_manager", "director", "admin"
        scope.all
      when "project_manager", "sales_manager"
        scope.where(created_by: user)
      when "worker"
        scope.joins(tasks: :task_assignees).where(task_assignees: { user_id: user.id }).distinct
      else
        scope.none
      end
    end
  end
end
