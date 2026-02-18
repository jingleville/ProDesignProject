class Tasks::CommentsController < ApplicationController
  before_action :set_project_and_task

  def create
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment
    @comment.save
    redirect_to project_task_path(@project, @task)
  end

  def destroy
    @comment = @task.comments.find(params[:id])
    authorize @comment
    @comment.destroy
    redirect_to project_task_path(@project, @task)
  end

  private

  def set_project_and_task
    @project = Project.find(params[:project_id])
    @task = @project.tasks.find(params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
