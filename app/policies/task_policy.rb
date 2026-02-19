class TaskPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    case user.role
    when "production_manager", "director", "admin"
      true
    when "project_manager", "sales_manager"
      record.project.created_by_id == user.id
    when "worker"
      record.assignee_id == user.id
    else
      false
    end
  end

  def create?
    user.project_manager? || user.sales_manager? || user.admin?
  end

  def update?
    user.admin? ||
      user.production_manager? ||
      (record.project.created_by_id == user.id && (user.project_manager? || user.sales_manager?))
  end

  def destroy?
    user.admin? || (user.project_manager? && record.project.created_by_id == user.id)
  end

  def update_approved_dates?
    user.production_manager? || user.admin?
  end

  def submit_for_approval?
    return false unless record.draft?
    return true if user.admin?
    (user.project_manager? || user.sales_manager?) && record.project.created_by_id == user.id
  end

  def approve?
    (user.production_manager? || user.admin?) && record.awaiting_production_approval?
  end

  def reject?
    (user.production_manager? || user.admin?) && record.awaiting_production_approval?
  end

  def start?
    record.assignee == user && record.approved? && record.dependencies_completed?
  end

  def complete?
    (record.assignee == user || user.production_manager? || user.admin?) && record.in_progress?
  end

  def assign?
    user.production_manager? || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "production_manager", "director", "admin"
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
