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
    @available_parent_tasks = @project.tasks.where.not(id: @task.id)
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
      @available_parent_tasks = @project.tasks.where.not(id: @task.id)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @task
    @available_dependencies = @project.tasks.where.not(id: @task.id)
    @available_parent_tasks = @project.tasks.where.not(id: [@task.id] + descendant_ids(@task))
  end

  def update
    authorize @task
    if @task.update(task_params)
      update_dependencies
      redirect_to project_task_path(@project, @task), notice: "Задача успешно обновлена."
    else
      @available_dependencies = @project.tasks.where.not(id: @task.id)
      @available_parent_tasks = @project.tasks.where.not(id: [@task.id] + descendant_ids(@task))
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
    NotificationService.task_status_changed(@task, current_user)
    redirect_to project_path(@project), notice: "Задача отправлена на согласование."
  end

  def approve
    authorize @task
    @task.update!(status: :approved, approved_by: current_user,
      approved_start_at: @task.preliminary_start_at,
      approved_due_at: @task.preliminary_due_at)
    NotificationService.task_status_changed(@task, current_user)
    redirect_to project_task_path(@project, @task), notice: "Задача согласована."
  end

  def reject
    authorize @task
    @task.update!(status: :rejected)
    NotificationService.task_status_changed(@task, current_user)
    redirect_to project_task_path(@project, @task), notice: "Задача отклонена."
  end

  def start
    authorize @task
    @task.update!(status: :in_progress)
    NotificationService.task_status_changed(@task, current_user)
    redirect_to project_task_path(@project, @task), notice: "Задача начата."
  end

  def complete
    authorize @task
    @task.update!(status: :completed, completed_at: Time.current)
    NotificationService.task_status_changed(@task, current_user)
    redirect_to project_task_path(@project, @task), notice: "Задача завершена."
  end

  def assign
    authorize @task
    user_ids = Array(params[:task][:assignee_ids]).reject(&:blank?).map(&:to_i)
    @task.task_assignees.destroy_all
    user_ids.each { |uid| @task.task_assignees.create!(user_id: uid) }
    @task.update!(assigned_by: current_user)
    NotificationService.task_assigned(@task, user_ids, current_user)
    redirect_to project_task_path(@project, @task), notice: "Исполнители назначены."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.includes(:assignees, :dependencies, :child_tasks, :parent_task).find(params[:id])
  end

  def task_params
    base = [:title, :description, :preliminary_start_at, :preliminary_due_at, :parent_task_id]
    base += [:approved_start_at, :approved_due_at] if current_user.production_manager? || current_user.is_admin?
    params.require(:task).permit(*base)
  end

  def update_dependencies
    if params[:task][:dependency_ids].present?
      @task.task_dependencies.destroy_all
      params[:task][:dependency_ids].reject(&:blank?).each do |dep_id|
        @task.task_dependencies.create(depends_on_task_id: dep_id)
      end
    end
  end

  def descendant_ids(task)
    result = []
    queue = task.child_tasks.pluck(:id)
    while queue.any?
      id = queue.shift
      result << id
      queue.concat(Task.where(parent_task_id: id).pluck(:id))
    end
    result
  end
end
