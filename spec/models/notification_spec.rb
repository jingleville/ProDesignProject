require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:event_type) }
    it { is_expected.to validate_presence_of(:message) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:actor).class_name("User").optional }
    it { is_expected.to belong_to(:notifiable).optional }
  end

  describe "data jsonb field" do
    it "stores arbitrary hash data" do
      notification = create(:notification, data: { task_id: 5, note: "test" })
      expect(notification.reload.data).to include("task_id" => 5, "note" => "test")
    end

    it "defaults data to empty hash" do
      notification = create(:notification)
      expect(notification.data).to eq({})
    end

    it "can store nested data structures" do
      notification = create(:notification, data: {
        task: { id: 1, title: "Test" },
        changes: ["status", "due_date"]
      })
      reloaded = notification.reload
      expect(reloaded.data["task"]["id"]).to eq(1)
    end
  end

  describe "read state" do
    it "is unread by default" do
      notification = create(:notification, :unread)
      expect(notification).not_to be_read
    end

    it "is read when read_at is set" do
      notification = create(:notification, :read)
      expect(notification).to be_read
    end
  end

  describe "#mark_read!" do
    it "sets read_at timestamp" do
      notification = create(:notification, :unread)
      notification.mark_read!
      expect(notification.read_at).to be_present
    end

    it "is idempotent" do
      notification = create(:notification, :read)
      original_read_at = notification.read_at
      notification.mark_read!
      expect(notification.reload.read_at).to be_within(1.second).of(original_read_at)
    end
  end

  describe "scopes" do
    it ".unread returns only unread notifications" do
      unread = create(:notification, :unread)
      read = create(:notification, :read)

      expect(Notification.unread).to include(unread)
      expect(Notification.unread).not_to include(read)
    end

    it ".recent orders by created_at desc" do
      older = create(:notification, created_at: 2.hours.ago)
      newer = create(:notification, created_at: 1.hour.ago)

      expect(Notification.recent.first).to eq(newer)
      expect(Notification.recent.last).to eq(older)
    end
  end
end
