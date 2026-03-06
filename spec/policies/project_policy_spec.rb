require "rails_helper"

RSpec.describe ProjectPolicy, type: :policy do
  subject { described_class }

  let(:admin)          { build(:user, :admin) }
  let(:director)       { build(:user, :director) }
  let(:project_manager) { build(:user, :project_manager) }
  let(:production_head) { build(:user, :production_head) }
  let(:executor)       { build(:user, :executor) }
  let(:sales_manager)  { build(:user, :sales_manager) }

  let(:project)        { build(:project, creator: project_manager) }

  permissions :index? do
    it "permits admin" do
      expect(subject).to permit(admin, project)
    end

    it "permits director" do
      expect(subject).to permit(director, project)
    end

    it "permits project_manager" do
      expect(subject).to permit(project_manager, project)
    end

    it "permits production_head" do
      expect(subject).to permit(production_head, project)
    end

    it "permits sales_manager" do
      expect(subject).to permit(sales_manager, project)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, project)
    end
  end

  permissions :show? do
    it "permits admin" do
      expect(subject).to permit(admin, project)
    end

    it "permits project manager who created it" do
      expect(subject).to permit(project_manager, project)
    end

    it "permits production_head" do
      expect(subject).to permit(production_head, project)
    end
  end

  permissions :create? do
    it "permits sales_manager to create projects" do
      expect(subject).to permit(sales_manager, project)
    end

    it "permits project_manager to create projects" do
      expect(subject).to permit(project_manager, project)
    end

    it "permits admin" do
      expect(subject).to permit(admin, project)
    end

    it "forbids executor from creating projects" do
      expect(subject).not_to permit(executor, project)
    end
  end

  permissions :update? do
    it "permits admin" do
      expect(subject).to permit(admin, project)
    end

    it "permits director" do
      expect(subject).to permit(director, project)
    end

    it "permits project_manager who owns the project" do
      expect(subject).to permit(project_manager, project)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, project)
    end
  end

  permissions :destroy? do
    it "permits admin" do
      expect(subject).to permit(admin, project)
    end

    it "permits director" do
      expect(subject).to permit(director, project)
    end

    it "forbids project_manager" do
      expect(subject).not_to permit(project_manager, project)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, project)
    end
  end

  permissions :archive? do
    it "permits admin" do
      expect(subject).to permit(admin, project)
    end

    it "permits director" do
      expect(subject).to permit(director, project)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, project)
    end
  end
end
