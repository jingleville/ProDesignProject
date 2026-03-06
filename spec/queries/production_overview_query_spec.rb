require "rails_helper"

RSpec.describe ProductionOverviewQuery, type: :query do
  let(:project) { create(:project, :active) }

  describe "#call" do
    it "groups tasks by assignee" do
      executor1 = create(:user, :executor)
      executor2 = create(:user, :executor)

      task1 = create(:task, :in_progress, project: project, assignee: executor1)
      task2 = create(:task, :in_progress, project: project, assignee: executor1)
      task3 = create(:task, :in_progress, project: project, assignee: executor2)

      result = described_class.new.call

      expect(result[executor1.id]).to include(task1, task2)
      expect(result[executor2.id]).to include(task3)
    end

    it "excludes cancelled and completed tasks from active view" do
      executor = create(:user, :executor)
      active_task = create(:task, :in_progress, project: project, assignee: executor)
      cancelled_task = create(:task, :cancelled, project: project, assignee: executor)
      completed_task = create(:task, :completed, project: project, assignee: executor)

      result = described_class.new.call

      group = result[executor.id] || []
      expect(group).to include(active_task)
      expect(group).not_to include(cancelled_task)
      expect(group).not_to include(completed_task)
    end

    it "returns empty hash when no active tasks" do
      result = described_class.new.call
      expect(result).to eq({})
    end
  end

  describe "#summary" do
    it "returns count of tasks per executor" do
      executor = create(:user, :executor)
      create_list(:task, 3, :in_progress, project: project, assignee: executor)

      summary = described_class.new.summary
      expect(summary[executor.id]).to eq(3)
    end
  end

  describe "#overloaded_executors" do
    it "returns executors with more tasks than the threshold" do
      overloaded = create(:user, :executor)
      normal = create(:user, :executor)

      create_list(:task, 6, :in_progress, project: project, assignee: overloaded)
      create_list(:task, 2, :in_progress, project: project, assignee: normal)

      result = described_class.new(threshold: 5).overloaded_executors
      expect(result).to include(overloaded)
      expect(result).not_to include(normal)
    end
  end
end
