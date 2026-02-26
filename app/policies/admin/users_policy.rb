class Admin::UsersPolicy < ApplicationPolicy
  def edit?
    user.admin? || user.director?
  end

  def update?
    user.admin? || user.director?
  end

  def destroy?
    user.admin? || user.director?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
