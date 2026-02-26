class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.recent.includes(:actor, :notifiable)
    current_user.notifications.unread.update_all(read_at: Time.current)
    skip_authorization
    skip_policy_scope
  end

  def read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_read!
    skip_authorization
    redirect_back fallback_location: notifications_path
  end

  def read_all
    current_user.notifications.unread.update_all(read_at: Time.current)
    skip_authorization
    redirect_to notifications_path
  end
end
