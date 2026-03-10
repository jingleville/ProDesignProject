require "rails_helper"

RSpec.describe TaskApprovalService, type: :service do
  let(:production_head) { create(:user, :production_head) }
  let(:project_manager) { create(:user, :project_manager) }

  describe "#approve" do
    let(:task) { create(:task, :awaiting_approval) }

    it "transitions task to approved status" do
      service = described_class.new(task, approver: production_head)
      service.approve

      expect(task.reload).to be_approved
    end

    it "sets approved_by to the approver" do
      service = described_class.new(task, approver: production_head)
      service.approve

      expect(task.approved_by).to eq(production_head)
    end

    it "creates a change log entry" do
      service = described_class.new(task, approver: production_head)
      expect { service.approve }.to change(ChangeLog, :count).by(1)
    end

    it "sends a notification to the task creator" do
      service = described_class.new(task, approver: production_head)
      expect { service.approve }.to change(Notification, :count).by_at_least(1)
    end
  end

  describe "#counter_propose" do
    let(:task) { create(:task, :awaiting_approval, plan_start_at: 3.days.from_now, plan_due_at: 10.days.from_now) }

    it "sets new plan dates as counter-proposal" do
      new_start = 5.days.from_now
      new_due = 15.days.from_now

      service = described_class.new(task, approver: production_head)
      service.counter_propose(start_at: new_start, due_at: new_due)

      expect(task.plan_start_at.to_date).to eq(new_start.to_date)
      expect(task.plan_due_at.to_date).to eq(new_due.to_date)
    end

    it "keeps task in awaiting_approval while counter-proposal is pending" do
      service = described_class.new(task, approver: production_head)
      service.counter_propose(
        start_at: 5.days.from_now,
        due_at: 15.days.from_now
      )

      expect(task.reload).to be_awaiting_approval
    end

    it "notifies project manager about counter-proposal" do
      task.update!(created_by: project_manager)
      service = described_class.new(task, approver: production_head)

      expect { service.counter_propose(start_at: 5.days.from_now, due_at: 15.days.from_now) }
        .to change(Notification, :count).by_at_least(1)
    end
  end

  describe "#reject" do
    let(:task) { create(:task, :awaiting_approval) }

    it "transitions task back to draft" do
      service = described_class.new(task, approver: production_head)
      service.reject(reason: "Dates not feasible")

      expect(task.reload).to be_draft
    end

    it "creates a change log with the rejection reason" do
      service = described_class.new(task, approver: production_head)
      service.reject(reason: "Dates not feasible")

      log = ChangeLog.last
      expect(log.new_value).to include("Dates not feasible")
    end
  end
end
