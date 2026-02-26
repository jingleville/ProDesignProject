class UserPolicy < ApplicationPolicy
  def edit?
    user.is_admin? || user.director?
  end

  def update?
    user.is_admin? || user.director?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
