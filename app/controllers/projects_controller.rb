class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :gantt]

  def index
    @projects = policy_scope(Project).includes(:creator, :tasks)
    @projects = @projects.where(status: params[:status]) if params[:status].present?
    @projects = @projects.order(created_at: :desc)
  end

  def show
    authorize @project
    @stages = @project.stages.includes(tasks: :assignee)
    @tasks  = @project.tasks.where(stage_id: nil).includes(:assignee, :dependencies)
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    @project.creator = current_user
    authorize @project
    if @project.save
      redirect_to @project, notice: "Проект успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
    if @project.update(project_params)
      redirect_to @project, notice: "Проект успешно обновлён."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy
    redirect_to projects_path, notice: "Проект успешно удалён."
  end

  def gantt
    authorize @project, :show?
    @tasks = @project.tasks.includes(:dependencies).order(:plan_start_at)
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :status, :planned_end_date)
  end
end
