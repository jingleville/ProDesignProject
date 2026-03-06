require "rails_helper"

RSpec.describe Task, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to belong_to(:assignee).class_name("User").optional }
    it { is_expected.to belong_to(:approved_by).class_name("User").optional }
    it { is_expected.to belong_to(:stage).optional }
    it { is_expected.to have_many(:task_dependencies).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:change_logs) }
  end

  describe "statuses" do
    it "defines all expected statuses" do
      expect(Task.statuses.keys).to contain_exactly(
        "draft", "awaiting_approval", "approved",
        "in_progress", "pending_confirmation", "completed", "cancelled"
      )
    end

    it "does not include legacy awaiting_production_approval" do
      expect(Task.statuses.keys).not_to include("awaiting_production_approval")
    end

    it "does not include legacy rejected status" do
      expect(Task.statuses.keys).not_to include("rejected")
    end
  end

  describe "date fields" do
    it "responds to plan_start_at" do
      task = build(:task)
      expect(task).to respond_to(:plan_start_at)
    end

    it "responds to plan_due_at" do
      task = build(:task)
      expect(task).to respond_to(:plan_due_at)
    end

    it "responds to approved_start_at" do
      task = build(:task)
      expect(task).to respond_to(:approved_start_at)
    end

    it "responds to approved_due_at" do
      task = build(:task)
      expect(task).to respond_to(:approved_due_at)
    end

    it "responds to actual_start_at" do
      task = build(:task)
      expect(task).to respond_to(:actual_start_at)
    end

    it "responds to actual_due_at" do
      task = build(:task)
      expect(task).to respond_to(:actual_due_at)
    end

    it "responds to approved_at" do
      task = build(:task)
      expect(task).to respond_to(:approved_at)
    end
  end

  describe "#overdue?" do
    it "returns false for a completed task" do
      task = build(:task, :completed, plan_due_at: 3.days.ago)
      expect(task.overdue?).to be false
    end

    it "returns true when approved_due_at is in the past and task is not complete" do
      task = build(:task, :in_progress, approved_due_at: 1.day.ago, plan_due_at: nil)
      expect(task.overdue?).to be true
    end

    it "returns true when plan_due_at is in the past and no approved_due_at" do
      task = build(:task, :in_progress, plan_due_at: 1.day.ago, approved_due_at: nil)
      expect(task.overdue?).to be true
    end

    it "returns false when due date is in the future" do
      task = build(:task, :in_progress, plan_due_at: 5.days.from_now, approved_due_at: nil)
      expect(task.overdue?).to be false
    end
  end

  describe "#approved_by_id and approved_at" do
    it "stores approval metadata" do
      approver = create(:user, :production_head)
      task = create(:task, :approved, approved_by: approver, approved_at: Time.current)

      expect(task.approved_by).to eq(approver)
      expect(task.approved_at).to be_present
    end
  end

  describe "#effective_due_date" do
    it "prefers approved_due_at over plan_due_at" do
      task = build(:task,
        plan_due_at: 10.days.from_now,
        approved_due_at: 5.days.from_now
      )
      expect(task.effective_due_date).to eq(task.approved_due_at)
    end

    it "falls back to plan_due_at when approved_due_at is nil" do
      task = build(:task, plan_due_at: 10.days.from_now, approved_due_at: nil)
      expect(task.effective_due_date).to eq(task.plan_due_at)
    end
  end

  describe "auto-completion callback" do
    it "triggers project completion check when task is completed" do
      project = create(:project, :active)
      task = create(:task, :in_progress, project: project)

      expect(project).to receive(:check_completion!)
      task.update!(status: :completed)
    end
  end
end
