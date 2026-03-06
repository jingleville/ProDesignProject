class NotificationService
  def self.notify(user:, actor:, event_type:, message:, notifiable: nil, data: {})
    Notification.create!(
      user: user,
      actor: actor,
      event_type: event_type.to_s,
      message: message,
      notifiable: notifiable,
      data: data
    )
  end

  def self.notify_task_assigned(task:, assignee:, actor:)
    notify(
      user: assignee,
      actor: actor,
      event_type: "task_assigned",
      message: "Вы назначены исполнителем задачи «#{task.title}»",
      notifiable: task,
      data: { task_id: task.id, task_title: task.title }
    )
  end

  def self.notify_task_status_changed(task:, actor:, old_status:, new_status:)
    recipients = [ task.created_by, task.assignee ].compact.uniq - [ actor ]
    recipients.each do |user|
      notify(
        user: user,
        actor: actor,
        event_type: "task_status_changed",
        message: "Статус задачи «#{task.title}» изменён",
        notifiable: task,
        data: { task_id: task.id, old_status: old_status.to_s, new_status: new_status.to_s }
      )
    end
  end

  def self.comment_added(comment, task, actor)
    recipients = [ task.created_by, task.assignee ].compact.uniq - [ actor ]
    recipients.each do |user|
      notify(
        user: user,
        actor: actor,
        event_type: "comment_added",
        message: "Новый комментарий к задаче «#{task.title}»",
        notifiable: task,
        data: { task_id: task.id, comment_id: comment.id }
      )
    end
  end

  def self.notify_project_completed(project:, actor:)
    recipients = [ project.creator ].compact.uniq - [ actor ]
    recipients.each do |user|
      notify(
        user: user,
        actor: actor,
        event_type: "project_completed",
        message: "Проект «#{project.name}» завершён",
        notifiable: project,
        data: { project_id: project.id }
      )
    end
  end
end
