class UserPolicy < ApplicationPolicy
  def edit?
    user.is_admin? || user.director?
  end

  def update?
    user.is_admin? || user.director?
  end

  def fire?
    (user.is_admin? || user.director?) && record != user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
