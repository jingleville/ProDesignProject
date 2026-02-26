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

    tasks = Task.where.not(status: [:completed, :draft])
      .where(
        "COALESCE(approved_due_at, preliminary_due_at) BETWEEN ? AND ?",
        Date.current, Date.current + 3.days
      )
      .includes(:assignees)

    tasks.each do |task|
      days_left = (task.due_date - Date.current).to_i
      assignees = task.assignees
      next if assignees.empty?

      already_notified_ids = Notification
        .where(notifiable: task, event_type: :deadline_approaching)
        .where("created_at > ?", 1.day.ago)
        .pluck(:user_id)

      unnotified = assignees.reject { |u| already_notified_ids.include?(u.id) }
      NotificationService.deadline_approaching(task, days_left) if unnotified.any?
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
