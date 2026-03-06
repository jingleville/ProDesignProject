require "rails_helper"

RSpec.describe TaskPolicy, type: :policy do
  subject { described_class }

  let(:admin)           { build(:user, :admin) }
  let(:production_head) { build(:user, :production_head) }
  let(:project_manager) { build(:user, :project_manager) }
  let(:executor)        { build(:user, :executor) }
  let(:other_executor)  { build(:user, :executor) }

  let(:project) { build(:project) }
  let(:task)    { build(:task, project: project, created_by: project_manager, assignee: executor) }

  permissions :index? do
    it "permits admin" do
      expect(subject).to permit(admin, task)
    end

    it "permits production_head" do
      expect(subject).to permit(production_head, task)
    end

    it "permits project_manager" do
      expect(subject).to permit(project_manager, task)
    end

    it "permits executor" do
      expect(subject).to permit(executor, task)
    end
  end

  permissions :show? do
    it "permits admin" do
      expect(subject).to permit(admin, task)
    end

    it "permits the assigned executor" do
      expect(subject).to permit(executor, task)
    end

    it "forbids unrelated executor" do
      expect(subject).not_to permit(other_executor, task)
    end
  end

  permissions :create? do
    it "permits project_manager" do
      expect(subject).to permit(project_manager, task)
    end

    it "permits admin" do
      expect(subject).to permit(admin, task)
    end

    it "forbids executor from creating tasks" do
      expect(subject).not_to permit(executor, task)
    end
  end

  permissions :update? do
    it "permits admin" do
      expect(subject).to permit(admin, task)
    end

    it "permits project_manager who created it" do
      expect(subject).to permit(project_manager, task)
    end

    it "forbids executor from updating task metadata" do
      expect(subject).not_to permit(executor, task)
    end
  end

  permissions :approve? do
    it "permits production_head" do
      expect(subject).to permit(production_head, task)
    end

    it "permits admin" do
      expect(subject).to permit(admin, task)
    end

    it "forbids project_manager from approving" do
      expect(subject).not_to permit(project_manager, task)
    end

    it "forbids executor from approving" do
      expect(subject).not_to permit(executor, task)
    end
  end

  permissions :start? do
    let(:approved_task) { build(:task, :approved, project: project, assignee: executor) }

    it "permits the assigned executor to start" do
      expect(subject).to permit(executor, approved_task)
    end

    it "forbids unrelated executor" do
      expect(subject).not_to permit(other_executor, approved_task)
    end
  end

  permissions :complete? do
    let(:in_progress_task) { build(:task, :in_progress, project: project, assignee: executor) }

    it "permits the assigned executor to complete" do
      expect(subject).to permit(executor, in_progress_task)
    end

    it "forbids unrelated executor" do
      expect(subject).not_to permit(other_executor, in_progress_task)
    end
  end

  permissions :destroy? do
    it "permits admin" do
      expect(subject).to permit(admin, task)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, task)
    end

    it "forbids project_manager" do
      expect(subject).not_to permit(project_manager, task)
    end
  end
end
