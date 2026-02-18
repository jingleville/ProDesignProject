class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_current_user
  after_action :verify_pundit_authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_current_user
    Current.user = current_user
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
