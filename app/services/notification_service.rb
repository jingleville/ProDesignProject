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
    recipients = ([ task.created_by, task.assignee ].compact + comment.mentioned_users.to_a).uniq - [ actor ]
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

  def self.notify_task_submitted(task:, actor:)
    recipients = User.where(role: [ :production_head, :director ])
    recipients.each do |user|
      notify(
        user: user,
        actor: actor,
        event_type: "task_submitted",
        message: "Задача «#{task.title}» отправлена на согласование",
        notifiable: task,
        data: { task_id: task.id, task_title: task.title }
      )
    end
  end

  def self.notify_task_overdue(task:, actor: nil)
    recipients = ([ task.created_by ] + User.where(role: [ :production_head, :director ]).to_a).uniq
    recipients.each do |user|
      notify(
        user: user,
        actor: actor,
        event_type: "task_overdue",
        message: "Задача «#{task.title}» просрочена",
        notifiable: task,
        data: { task_id: task.id, task_title: task.title }
      )
    end
  end

  def self.notify_mentioned(comment:, actor:)
    recipients = comment.mentioned_users.to_a - [ actor ]
    recipients.each do |user|
      notify(
        user: user,
        actor: actor,
        event_type: "mentioned",
        message: "Вы упомянуты в комментарии к задаче",
        notifiable: comment,
        data: { comment_id: comment.id }
      )
    end
  end

  def self.notify_dependency_overdue(task:, dependent_task:, actor: nil)
    recipients = ([ task.created_by ] + User.where(role: [ :production_head, :director ]).to_a).uniq
    recipients.each do |user|
      notify(
        user: user,
        actor: actor,
        event_type: "dependency_overdue",
        message: "Зависимая задача «#{task.title}» просрочена и блокирует «#{dependent_task.title}»",
        notifiable: task,
        data: { task_id: task.id, dependent_task_id: dependent_task.id }
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
