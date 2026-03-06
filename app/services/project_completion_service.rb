class ProjectCompletionService
  def initialize(project)
    @project = project
  end

  def call
    return unless @project.active?

    active_tasks = @project.tasks.where.not(status: :cancelled)
    return if active_tasks.empty?
    return unless active_tasks.all?(&:completed?)

    @project.update!(status: :completed)

    ChangeLog.create!(
      entity_type: "Project",
      entity_id: @project.id,
      field_name: "status",
      old_value: "active",
      new_value: "completed",
      changed_by: @project.creator,
      changed_at: Time.current
    )

    NotificationService.notify_project_completed(project: @project, actor: nil)
  end
end
