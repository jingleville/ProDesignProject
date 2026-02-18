class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:show, :edit, :update, :destroy, :submit_for_approval, :approve, :reject, :start, :complete, :assign]

  def show
    authorize @task
  end

  def new
    @task = @project.tasks.build
    authorize @task
    @available_dependencies = @project.tasks.where.not(id: @task.id)
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
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @task
    @available_dependencies = @project.tasks.where.not(id: @task.id)
  end

  def update
    authorize @task
    if @task.update(task_params)
      update_dependencies
      redirect_to project_task_path(@project, @task), notice: "Задача успешно обновлена."
    else
      @available_dependencies = @project.tasks.where.not(id: @task.id)
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
    @task.update!(status: :awaiting_production_approval)
    redirect_to project_task_path(@project, @task), notice: "Задача отправлена на согласование."
  end

  def approve
    authorize @task
    @task.update!(
      status: :approved,
      approved_by: current_user,
      approved_start_at: @task.preliminary_start_at,
      approved_due_at: @task.preliminary_due_at
    )
    redirect_to project_task_path(@project, @task), notice: "Задача согласована."
  end

  def reject
    authorize @task
    @task.update!(status: :rejected)
    redirect_to project_task_path(@project, @task), notice: "Задача отклонена."
  end

  def start
    authorize @task
    @task.update!(status: :in_progress)
    redirect_to project_task_path(@project, @task), notice: "Задача начата."
  end

  def complete
    authorize @task
    @task.update!(status: :completed, completed_at: Time.current)
    redirect_to project_task_path(@project, @task), notice: "Задача завершена."
  end

  def assign
    authorize @task
    @task.update!(assignee_id: params[:task][:assignee_id], assigned_by: current_user)
    redirect_to project_task_path(@project, @task), notice: "Исполнитель назначен."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :preliminary_start_at, :preliminary_due_at, :approved_start_at, :approved_due_at)
  end

  def update_dependencies
    if params[:task][:dependency_ids].present?
      @task.task_dependencies.destroy_all
      params[:task][:dependency_ids].reject(&:blank?).each do |dep_id|
        @task.task_dependencies.create(depends_on_task_id: dep_id)
      end
    end
  end
end
