require "rails_helper"

RSpec.describe TaskPlanner, type: :query do
  let(:executor) { create(:user, :executor) }
  let(:project)  { create(:project, :active) }

  describe "#day_plan" do
    it "returns tasks that start today for the given executor" do
      today_task = create(:task, :approved,
        project: project,
        assignee: executor,
        approved_start_at: Date.current,
        approved_due_at: Date.current + 3.days
      )
      future_task = create(:task, :approved,
        project: project,
        assignee: executor,
        approved_start_at: 3.days.from_now,
        approved_due_at: 7.days.from_now
      )

      planner = described_class.new(date: Date.current)
      result = planner.day_plan(executor)

      expect(result).to include(today_task)
      expect(result).not_to include(future_task)
    end

    it "excludes tasks from other executors" do
      other_executor = create(:user, :executor)
      other_task = create(:task, :approved,
        project: project,
        assignee: other_executor,
        approved_start_at: Date.current,
        approved_due_at: 3.days.from_now
      )

      planner = described_class.new(date: Date.current)
      result = planner.day_plan(executor)

      expect(result).not_to include(other_task)
    end
  end

  describe "#week_plan" do
    it "returns tasks that fall within the current week" do
      week_task = create(:task, :approved,
        project: project,
        assignee: executor,
        approved_start_at: Date.current,
        approved_due_at: Date.current.end_of_week
      )
      next_week_task = create(:task, :approved,
        project: project,
        assignee: executor,
        approved_start_at: Date.current.next_week,
        approved_due_at: Date.current.next_week + 5.days
      )

      planner = described_class.new(date: Date.current)
      result = planner.week_plan(executor)

      expect(result).to include(week_task)
      expect(result).not_to include(next_week_task)
    end
  end

  describe "#production_overview" do
    it "returns tasks grouped by executor" do
      executor2 = create(:user, :executor)

      task1 = create(:task, :in_progress, project: project, assignee: executor)
      task2 = create(:task, :in_progress, project: project, assignee: executor2)

      planner = described_class.new(date: Date.current)
      overview = planner.production_overview

      expect(overview.keys).to include(executor.id, executor2.id)
      expect(overview[executor.id]).to include(task1)
      expect(overview[executor2.id]).to include(task2)
    end
  end
end
