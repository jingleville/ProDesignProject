class TaskPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.project_manager? || user.admin? || user.director?
  end

  def update?
    user.project_manager? || user.admin? || user.director? || user.production_manager?
  end

  def destroy?
    user.admin? || user.project_manager?
  end

  def submit_for_approval?
    (user.project_manager? || user.admin?) && record.draft?
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
      scope.all
    end
  end
end
