class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:show, :edit, :update, :destroy,
                                  :submit_for_approval, :approve, :reject,
                                  :start, :complete, :confirm_completion]

  def show
    authorize @task
    @comments = @task.comments.includes(:user).order(:created_at)
  end

  def new
    @task = @project.tasks.build
    authorize @task
    @available_dependencies = @project.tasks.where.not(id: @task.id)
    @stages = @project.stages
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.created_by = current_user
    authorize @task
    if @task.save
      update_dependencies
      redirect_to project_task_path(@project, @task), notice: "Задача успешно создана."
    else
      @available_dependencies = @project.tasks.where.not(id: @task.id)
      @stages = @project.stages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @task
    @available_dependencies = @project.tasks.where.not(id: @task.id)
    @stages = @project.stages
  end

  def update
    authorize @task
    if @task.update(task_params)
      update_dependencies
      redirect_to project_task_path(@project, @task), notice: "Задача успешно обновлена."
    else
      @available_dependencies = @project.tasks.where.not(id: @task.id)
      @stages = @project.stages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    @task.destroy
    redirect_to project_path(@project), notice: "Задача успешно удалена."
  end

  def submit_for_approval
    authorize @task
    @task.update!(status: :awaiting_approval)
    redirect_to project_path(@project), notice: "Задача отправлена на согласование."
  end

  def approve
    authorize @task
    TaskApprovalService.new(@task, approver: current_user).approve
    redirect_to project_task_path(@project, @task), notice: "Задача согласована."
  end

  def reject
    authorize @task
    reason = params[:reason].presence || "Отклонено"
    TaskApprovalService.new(@task, approver: current_user).reject(reason: reason)
    redirect_to project_task_path(@project, @task), notice: "Задача отклонена."
  end

  def start
    authorize @task
    TaskStateMachine.new(@task, actor: current_user).start!
    redirect_to project_task_path(@project, @task), notice: "Задача начата."
  end

  def complete
    authorize @task
    TaskStateMachine.new(@task, actor: current_user).complete!
    redirect_to project_task_path(@project, @task), notice: "Задача отправлена на подтверждение."
  end

  def confirm_completion
    authorize @task, :approve?
    TaskStateMachine.new(@task, actor: current_user).confirm!
    ProjectCompletionService.new(@project).call
    redirect_to project_task_path(@project, @task), notice: "Задача завершена."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.includes(:assignee, :dependencies).find(params[:id])
  end

  def task_params
    base = [:title, :description, :plan_start_at, :plan_due_at, :assignee_id, :stage_id]
    base += [:approved_start_at, :approved_due_at] if current_user.production_head? || current_user.is_admin?
    params.require(:task).permit(*base)
  end

  def update_dependencies
    return unless params[:task][:dependency_ids].present?

    @task.task_dependencies.destroy_all
    params[:task][:dependency_ids].reject(&:blank?).each do |dep_id|
      @task.task_dependencies.create(depends_on_task_id: dep_id)
    end
  end
end
