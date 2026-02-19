class BudgetItemsController < ApplicationController
  before_action :set_project
  before_action :set_task
  before_action :set_budget_item, only: [:update, :destroy]

  def create
    @budget_item = @task.budget_items.build(budget_item_params)
    authorize @budget_item
    if @budget_item.save
      redirect_to project_task_path(@project, @task), notice: "Позиция сметы добавлена."
    else
      redirect_to project_task_path(@project, @task), alert: @budget_item.errors.full_messages.join(", ")
    end
  end

  def update
    authorize @budget_item
    if @budget_item.update(budget_item_params)
      redirect_to project_task_path(@project, @task), notice: "Позиция сметы обновлена."
    else
      redirect_to project_task_path(@project, @task), alert: @budget_item.errors.full_messages.join(", ")
    end
  end

  def destroy
    authorize @budget_item
    @budget_item.destroy
    redirect_to project_task_path(@project, @task), notice: "Позиция сметы удалена."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def set_budget_item
    @budget_item = @task.budget_items.find(params[:id])
  end

  def budget_item_params
    params.require(:budget_item).permit(:material, :format, :quantity, :price)
  end
end
