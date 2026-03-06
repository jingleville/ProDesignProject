require "rails_helper"

RSpec.describe OverdueTasksQuery, type: :query do
  let(:project) { create(:project, :active) }

  describe ".overdue_start" do
    it "returns tasks where approved_start_at is in the past and status is approved" do
      overdue_start_task = create(:task, :approved,
        project: project,
        approved_start_at: 3.days.ago,
        approved_due_at: 5.days.from_now
      )
      on_time_task = create(:task, :approved,
        project: project,
        approved_start_at: Date.current,
        approved_due_at: 5.days.from_now
      )

      result = described_class.overdue_start

      expect(result).to include(overdue_start_task)
      expect(result).not_to include(on_time_task)
    end

    it "excludes in_progress tasks (already started)" do
      in_progress = create(:task, :in_progress,
        project: project,
        approved_start_at: 3.days.ago,
        actual_start_at: 2.days.ago
      )

      result = described_class.overdue_start
      expect(result).not_to include(in_progress)
    end
  end

  describe ".overdue_deadline" do
    it "returns tasks where approved_due_at is in the past and task is not completed or cancelled" do
      overdue_task = create(:task, :in_progress,
        project: project,
        approved_due_at: 2.days.ago
      )
      completed_task = create(:task, :completed,
        project: project,
        approved_due_at: 2.days.ago
      )
      future_task = create(:task, :in_progress,
        project: project,
        approved_due_at: 5.days.from_now
      )

      result = described_class.overdue_deadline

      expect(result).to include(overdue_task)
      expect(result).not_to include(completed_task)
      expect(result).not_to include(future_task)
    end

    it "uses plan_due_at when approved_due_at is nil" do
      task_with_plan_overdue = create(:task, :in_progress,
        project: project,
        plan_due_at: 3.days.ago,
        approved_due_at: nil
      )

      result = described_class.overdue_deadline
      expect(result).to include(task_with_plan_overdue)
    end
  end

  describe ".all_overdue" do
    it "returns union of overdue_start and overdue_deadline" do
      overdue_start = create(:task, :approved,
        project: project,
        approved_start_at: 5.days.ago,
        approved_due_at: 10.days.from_now
      )
      overdue_deadline = create(:task, :in_progress,
        project: project,
        approved_due_at: 1.day.ago
      )

      result = described_class.all_overdue

      expect(result).to include(overdue_start)
      expect(result).to include(overdue_deadline)
    end
  end
end
