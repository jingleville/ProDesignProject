class NotificationService
  STATUS_TO_EVENT = {
    "awaiting_production_approval" => :task_awaiting_production_approval,
    "approved"                     => :task_approved,
    "rejected"                     => :task_rejected,
    "in_progress"                  => :task_started,
    "completed"                    => :task_completed
  }.freeze

  MESSAGES = {
    task_assigned:                     "Вы назначены исполнителем задачи «%{task}»",
    task_awaiting_production_approval: "Задача «%{task}» отправлена на согласование",
    task_approved:                     "Задача «%{task}» согласована",
    task_rejected:                     "Задача «%{task}» отклонена",
    task_started:                      "Задача «%{task}» взята в работу",
    task_completed:                    "Задача «%{task}» завершена",
    comment_added:                     "%{actor} оставил(а) комментарий к задаче «%{task}»",
    deadline_approaching:              "Задача «%{task}» должна быть выполнена через %{days} дн."
  }.freeze

  def self.task_status_changed(task, actor)
    event = STATUS_TO_EVENT[task.status]
    return unless event

    recipients = recipients_for_status(task)
    message = MESSAGES[event] % { task: task.title }
    notify_users(recipients, actor, task, event, message)
  end

  def self.task_assigned(task, new_user_ids, actor)
    users = User.where(id: new_user_ids)
    message = MESSAGES[:task_assigned] % { task: task.title }
    notify_users(users, actor, task, :task_assigned, message)
  end

  def self.comment_added(comment, task, actor)
    recipients = (task.assignees.to_a + [task.created_by]).uniq - [actor]
    message = MESSAGES[:comment_added] % { actor: actor.full_name, task: task.title }
    notify_users(recipients, actor, comment, :comment_added, message)
  end

  def self.deadline_approaching(task, days)
    message = MESSAGES[:deadline_approaching] % { task: task.title, days: days }
    notify_users(task.assignees, nil, task, :deadline_approaching, message)
  end

  private

  def self.recipients_for_status(task)
    case task.status
    when "awaiting_production_approval"
      User.where(role: [:production_manager, :admin, :director])
    when "approved", "rejected"
      (task.assignees.to_a + [task.created_by]).uniq
    when "in_progress"
      ([task.created_by] + User.where(role: :production_manager).to_a).uniq
    when "completed"
      ([task.created_by, task.project.created_by] +
        User.where(role: :production_manager).to_a).uniq
    else
      []
    end
  end

  def self.notify_users(users, actor, notifiable, event_type, message)
    Array(users).each do |user|
      next if actor && user == actor
      Notification.create!(
        user: user,
        actor: actor,
        notifiable: notifiable,
        event_type: event_type,
        message: message
      )
    end
  end
end
