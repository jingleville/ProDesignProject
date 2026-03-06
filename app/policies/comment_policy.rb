class CommentPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    true
  end

  def update?
    user.is_admin? || record.user == user
  end

  def destroy?
    user.is_admin? || record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
