class Admin::UsersController < ApplicationController
  # skip_after_action :verify_authorized
  # skip_after_action :verify_policy_scoped

  before_action :require_admin_or_director
  before_action :set_user, only: [ :edit, :update ]

  def index
    @users = policy_scope(User).order(:last_name, :first_name)
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Роль пользователя #{@user.full_name} обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to redirect_to admin_users_path, notice: "Пользователь удален."
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role)
  end

  def require_admin_or_director
    unless current_user.is_admin? || current_user.director?
      flash[:alert] = "У вас нет прав для этого действия."
      redirect_to root_path
    end
  end
end
