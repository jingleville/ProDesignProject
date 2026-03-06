class EstimateItemPolicy < ApplicationPolicy
  def index?
    !user.executor?
  end

  def show?
    user.is_admin? || user.sales_manager? || user.project_manager? || user.director?
  end

  def create?
    user.is_admin? || user.sales_manager? || user.project_manager?
  end

  def update?
    user.is_admin? || user.sales_manager?
  end

  def destroy?
    user.is_admin? || user.sales_manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.executor?
        scope.none
      else
        scope.all
      end
    end
  end
end
