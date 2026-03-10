class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_current_user
  before_action :check_deadlines, if: :user_signed_in?
  after_action :verify_pundit_authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_current_user
    Current.user = current_user
  end

  def check_deadlines
    last_check = session[:deadline_check_at]
    return if last_check && Time.parse(last_check) > 1.hour.ago

    session[:deadline_check_at] = Time.current.to_s

    tasks = Task.where.not(status: [:completed, :cancelled, :draft])
      .where(
        "plan_due_at BETWEEN ? AND ?",
        Date.current, Date.current + 3.days
      )
      .where.not(assignee_id: nil)
      .includes(:assignee)

    tasks.each do |task|
      days_left = (task.effective_due_date.to_date - Date.current).to_i
      assignee = task.assignee
      next unless assignee

      already_notified = Notification
        .where(notifiable: task, event_type: :deadline_approaching, user: assignee)
        .where("created_at > ?", 1.day.ago)
        .exists?

      unless already_notified
        NotificationService.notify(
          user: assignee,
          actor: nil,
          event_type: "deadline_approaching",
          message: "Задача «#{task.title}» должна быть выполнена через #{days_left} дн.",
          notifiable: task,
          data: { task_id: task.id, days_left: days_left }
        )
      end
    end
  end

  def user_not_authorized
    flash[:alert] = "У вас нет прав для этого действия."
    redirect_back(fallback_location: root_path)
  end

  def verify_pundit_authorization
    return if devise_controller?

    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end
end
