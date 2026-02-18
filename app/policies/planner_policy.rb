class PlannerPolicy < ApplicationPolicy
  def index?
    1/0
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "director", "admin"
        # Директор и админ видят все задачи
        scope.all
      else
        # Обычные пользователи видят только свои задачи
        scope.joins(:assignee).where(assignee: { id: user.id })
      end
    end
  end
end
