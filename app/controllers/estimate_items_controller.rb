class EstimateItemsController < ApplicationController
  before_action :set_project
  before_action :set_estimate_item, only: [:update, :destroy]

  def create
    @estimate_item = @project.estimate_items.build(estimate_item_params)
    authorize @estimate_item
    if @estimate_item.save
      redirect_to project_path(@project), notice: "Позиция добавлена."
    else
      redirect_to project_path(@project), alert: @estimate_item.errors.full_messages.join(", ")
    end
  end

  def update
    authorize @estimate_item
    if @estimate_item.update(estimate_item_params)
      redirect_to project_path(@project), notice: "Позиция обновлена."
    else
      redirect_to project_path(@project), alert: @estimate_item.errors.full_messages.join(", ")
    end
  end

  def destroy
    authorize @estimate_item
    @estimate_item.destroy
    redirect_to project_path(@project), notice: "Позиция удалена."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_estimate_item
    @estimate_item = @project.estimate_items.find(params[:id])
  end

  def estimate_item_params
    params.require(:estimate_item).permit(:name, :quantity, :unit_price)
  end
end
