class CommentPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    record.user == user || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
