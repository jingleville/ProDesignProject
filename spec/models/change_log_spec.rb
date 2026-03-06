require "rails_helper"

RSpec.describe ChangeLog, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:entity_type) }
    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:field_name) }
    it { is_expected.to validate_presence_of(:changed_at) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:changed_by).class_name("User") }
  end

  describe "fields" do
    it "stores entity_type and entity_id" do
      log = create(:change_log, entity_type: "Task", entity_id: 42)
      expect(log.entity_type).to eq("Task")
      expect(log.entity_id).to eq(42)
    end

    it "stores old and new values" do
      log = create(:change_log, old_value: "draft", new_value: "awaiting_approval")
      expect(log.old_value).to eq("draft")
      expect(log.new_value).to eq("awaiting_approval")
    end

    it "stores field_name" do
      log = create(:change_log, field_name: "status")
      expect(log.field_name).to eq("status")
    end

    it "stores changed_at timestamp" do
      time = Time.current
      log = create(:change_log, changed_at: time)
      expect(log.changed_at).to be_within(1.second).of(time)
    end
  end

  describe "scopes" do
    it "can filter by entity_type" do
      task_log = create(:change_log, entity_type: "Task")
      project_log = create(:change_log, :for_project)

      expect(ChangeLog.where(entity_type: "Task")).to include(task_log)
      expect(ChangeLog.where(entity_type: "Task")).not_to include(project_log)
    end

    it "can filter by entity_id to get all changes for a record" do
      log1 = create(:change_log, entity_type: "Task", entity_id: 1)
      log2 = create(:change_log, entity_type: "Task", entity_id: 2)

      expect(ChangeLog.where(entity_type: "Task", entity_id: 1)).to include(log1)
      expect(ChangeLog.where(entity_type: "Task", entity_id: 1)).not_to include(log2)
    end
  end

  describe "not AuditLog" do
    it "is a distinct model from AuditLog" do
      expect { AuditLog }.not_to raise_error
      expect(ChangeLog).not_to eq(AuditLog)
    end
  end
end
