class BudgetItemPolicy < ApplicationPolicy
  def create?
    TaskPolicy.new(user, record.task).update?
  end

  def update?
    TaskPolicy.new(user, record.task).update?
  end

  def destroy?
    TaskPolicy.new(user, record.task).update?
  end
end
