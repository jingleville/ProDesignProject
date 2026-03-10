require "rails_helper"

RSpec.describe TaskStateMachine, type: :service do
  let(:production_head) { create(:user, :production_head) }
  let(:executor) { create(:user, :executor) }
  let(:project_manager) { create(:user, :project_manager) }

  describe "transitions from draft" do
    let(:task) { create(:task, :draft) }

    it "can transition to awaiting_approval" do
      machine = described_class.new(task, actor: project_manager)
      expect { machine.submit! }.to change { task.status }.from("draft").to("awaiting_approval")
    end

    it "cannot directly transition to in_progress" do
      machine = described_class.new(task, actor: project_manager)
      expect { machine.start! }.to raise_error(TaskStateMachine::InvalidTransition)
    end
  end

  describe "transitions from awaiting_approval" do
    let(:task) { create(:task, :awaiting_approval) }

    it "can be approved by production_head" do
      machine = described_class.new(task, actor: production_head)
      expect { machine.approve! }.to change { task.status }.to("approved")
    end

    it "sets approved_by when approved" do
      machine = described_class.new(task, actor: production_head)
      machine.approve!

      expect(task.approved_by).to eq(production_head)
    end

    it "can be cancelled" do
      machine = described_class.new(task, actor: production_head)
      expect { machine.cancel! }.to change { task.status }.to("cancelled")
    end
  end

  describe "transitions from approved" do
    let(:task) { create(:task, :approved) }

    it "can transition to in_progress" do
      machine = described_class.new(task, actor: executor)
      expect { machine.start! }.to change { task.status }.to("in_progress")
    end

    it "sets actual_start_at when started" do
      machine = described_class.new(task, actor: executor)
      machine.start!

      expect(task.actual_start_at).to be_present
    end
  end

  describe "transitions from in_progress" do
    let(:task) { create(:task, :in_progress) }

    it "can transition to pending_confirmation" do
      machine = described_class.new(task, actor: executor)
      expect { machine.complete! }.to change { task.status }.to("pending_confirmation")
    end

    it "sets actual_due_at when moved to pending_confirmation" do
      machine = described_class.new(task, actor: executor)
      machine.complete!

      expect(task.actual_due_at).to be_present
    end
  end

  describe "transitions from pending_confirmation" do
    let(:task) { create(:task, :pending_confirmation) }

    it "can be confirmed as completed by production_head" do
      machine = described_class.new(task, actor: production_head)
      expect { machine.confirm! }.to change { task.status }.to("completed")
    end

    it "can be sent back to in_progress if rejected" do
      machine = described_class.new(task, actor: production_head)
      expect { machine.reject_completion! }.to change { task.status }.to("in_progress")
    end
  end

  describe "cancellation" do
    it "can cancel a draft task" do
      task = create(:task, :draft)
      machine = described_class.new(task, actor: project_manager)
      expect { machine.cancel! }.to change { task.status }.to("cancelled")
    end

    it "cannot cancel a completed task" do
      task = create(:task, :completed)
      machine = described_class.new(task, actor: project_manager)
      expect { machine.cancel! }.to raise_error(TaskStateMachine::InvalidTransition)
    end
  end
end
