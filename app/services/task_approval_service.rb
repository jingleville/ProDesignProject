class TaskApprovalService
  def initialize(task, approver:)
    @task = task
    @approver = approver
  end

  def approve
    @task.update!(
      status: :approved,
      approved_by: @approver
    )
    log_change("status", @task.status_before_last_save, "approved")
    NotificationService.notify_task_status_changed(
      task: @task,
      actor: @approver,
      old_status: @task.status_before_last_save.to_s,
      new_status: "approved"
    )
  end

  def counter_propose(start_at:, due_at:)
    @task.update!(
      plan_start_at: start_at,
      plan_due_at: due_at
    )
    NotificationService.notify(
      user: @task.created_by,
      actor: @approver,
      event_type: "counter_proposal",
      message: "Предложены новые сроки для задачи «#{@task.title}»",
      notifiable: @task,
      data: { task_id: @task.id }
    )
  end

  def reject(reason:)
    old_status = @task.status
    @task.update!(status: :draft)
    log_change("status", old_status, "draft: #{reason}")
    NotificationService.notify(
      user: @task.created_by,
      actor: @approver,
      event_type: "dates_rejected",
      message: "Сроки задачи «#{@task.title}» отклонены",
      notifiable: @task,
      data: { task_id: @task.id, reason: reason }
    )
  end

  private

  def log_change(field, old_val, new_val)
    ChangeLog.create!(
      entity_type: "Task",
      entity_id: @task.id,
      field_name: field,
      old_value: old_val.to_s,
      new_value: new_val.to_s,
      changed_by: @approver,
      changed_at: Time.current
    )
  end
end
