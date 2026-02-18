class Projects::CommentsController < ApplicationController
  before_action :set_project

  def create
    @comment = @project.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment
    @comment.save
    redirect_to project_path(@project)
  end

  def destroy
    @comment = @project.comments.find(params[:id])
    authorize @comment
    @comment.destroy
    redirect_to project_path(@project)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
