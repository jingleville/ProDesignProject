class TaskPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.is_admin? || user.production_head? || user.project_manager? ||
      record.assignee == user
  end

  def create?
    user.project_manager? || user.sales_manager? || user.is_admin?
  end

  def update?
    user.is_admin? ||
      (user.project_manager? && record.created_by_id == user.id)
  end

  def approve?
    user.production_head? || user.is_admin?
  end

  def start?
    record.assignee == user || user.production_head?
  end

  def complete?
    record.assignee == user
  end

  def destroy?
    user.is_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "production_head", "director", "admin"
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
