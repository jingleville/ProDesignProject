require "rails_helper"

RSpec.describe NotificationService, type: :service do
  let(:actor) { create(:user, :project_manager) }
  let(:recipient) { create(:user, :executor) }

  describe ".notify" do
    it "creates a notification for the given user" do
      task = create(:task)
      expect {
        NotificationService.notify(
          user: recipient,
          actor: actor,
          event_type: "task_assigned",
          message: "You have been assigned a task",
          notifiable: task,
          data: { task_id: task.id }
        )
      }.to change(Notification, :count).by(1)
    end

    it "sets the data jsonb field" do
      task = create(:task)
      NotificationService.notify(
        user: recipient,
        actor: actor,
        event_type: "task_assigned",
        message: "You have been assigned a task",
        notifiable: task,
        data: { task_id: task.id, priority: "high" }
      )

      notification = Notification.last
      expect(notification.data["task_id"]).to eq(task.id)
      expect(notification.data["priority"]).to eq("high")
    end

    it "associates the notifiable record" do
      task = create(:task)
      NotificationService.notify(
        user: recipient,
        actor: actor,
        event_type: "task_assigned",
        message: "Task assigned",
        notifiable: task,
        data: {}
      )

      notification = Notification.last
      expect(notification.notifiable).to eq(task)
    end
  end

  describe ".notify_task_assigned" do
    it "notifies the assignee" do
      task = create(:task)
      expect {
        NotificationService.notify_task_assigned(task: task, assignee: recipient, actor: actor)
      }.to change(Notification, :count).by(1)
    end

    it "uses correct event_type" do
      task = create(:task)
      NotificationService.notify_task_assigned(task: task, assignee: recipient, actor: actor)

      expect(Notification.last.event_type).to eq("task_assigned")
    end
  end

  describe ".notify_task_status_changed" do
    it "notifies the task creator" do
      task = create(:task, created_by: recipient)
      expect {
        NotificationService.notify_task_status_changed(
          task: task,
          actor: actor,
          old_status: "draft",
          new_status: "awaiting_approval"
        )
      }.to change(Notification, :count).by_at_least(1)
    end

    it "includes status change data in notification" do
      task = create(:task, created_by: recipient)
      NotificationService.notify_task_status_changed(
        task: task,
        actor: actor,
        old_status: "draft",
        new_status: "awaiting_approval"
      )

      notification = Notification.last
      expect(notification.data["old_status"]).to eq("draft")
      expect(notification.data["new_status"]).to eq("awaiting_approval")
    end
  end

  describe ".notify_project_completed" do
    it "notifies project creator" do
      project = create(:project, :active)
      create(:task, :completed, project: project)

      expect {
        NotificationService.notify_project_completed(project: project, actor: actor)
      }.to change(Notification, :count).by_at_least(1)
    end
  end
end
