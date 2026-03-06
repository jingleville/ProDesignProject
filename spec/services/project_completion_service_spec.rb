require "rails_helper"

RSpec.describe ProjectCompletionService, type: :service do
  describe "#call" do
    context "when all tasks are completed" do
      it "marks the project as completed" do
        project = create(:project, :active)
        create(:task, :completed, project: project)
        create(:task, :completed, project: project)

        service = described_class.new(project)
        service.call

        expect(project.reload).to be_completed
      end

      it "creates a change log entry for status change" do
        project = create(:project, :active)
        create(:task, :completed, project: project)

        service = described_class.new(project)
        expect { service.call }.to change(ChangeLog, :count).by_at_least(1)
      end

      it "sends notifications to project stakeholders" do
        project = create(:project, :active)
        creator = project.creator
        create(:task, :completed, project: project)

        service = described_class.new(project)
        expect { service.call }.to change(Notification, :count).by_at_least(1)
      end
    end

    context "when some tasks are not completed" do
      it "does not mark the project as completed" do
        project = create(:project, :active)
        create(:task, :completed, project: project)
        create(:task, :in_progress, project: project)

        service = described_class.new(project)
        service.call

        expect(project.reload).to be_active
      end
    end

    context "when project has cancelled tasks" do
      it "ignores cancelled tasks when checking completion" do
        project = create(:project, :active)
        create(:task, :completed, project: project)
        create(:task, :cancelled, project: project)

        service = described_class.new(project)
        service.call

        expect(project.reload).to be_completed
      end
    end

    context "when project is not active" do
      it "does nothing for archived projects" do
        project = create(:project, :archived)
        create(:task, :completed, project: project)

        service = described_class.new(project)
        expect { service.call }.not_to change { project.reload.status }
      end
    end
  end
end
