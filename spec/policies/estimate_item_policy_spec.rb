require "rails_helper"

RSpec.describe EstimateItemPolicy, type: :policy do
  subject { described_class }

  let(:admin)          { build(:user, :admin) }
  let(:director)       { build(:user, :director) }
  let(:sales_manager)  { build(:user, :sales_manager) }
  let(:project_manager) { build(:user, :project_manager) }
  let(:production_head) { build(:user, :production_head) }
  let(:executor)       { build(:user, :executor) }

  let(:project)        { build(:project) }
  let(:estimate_item)  { build(:estimate_item, project: project) }

  permissions :index? do
    it "permits admin" do
      expect(subject).to permit(admin, estimate_item)
    end

    it "permits director" do
      expect(subject).to permit(director, estimate_item)
    end

    it "permits sales_manager" do
      expect(subject).to permit(sales_manager, estimate_item)
    end

    it "permits project_manager" do
      expect(subject).to permit(project_manager, estimate_item)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, estimate_item)
    end
  end

  permissions :show? do
    it "permits admin" do
      expect(subject).to permit(admin, estimate_item)
    end

    it "permits sales_manager" do
      expect(subject).to permit(sales_manager, estimate_item)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, estimate_item)
    end
  end

  permissions :create? do
    it "permits sales_manager to add estimate items" do
      expect(subject).to permit(sales_manager, estimate_item)
    end

    it "permits project_manager" do
      expect(subject).to permit(project_manager, estimate_item)
    end

    it "permits admin" do
      expect(subject).to permit(admin, estimate_item)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, estimate_item)
    end

    it "forbids production_head" do
      expect(subject).not_to permit(production_head, estimate_item)
    end
  end

  permissions :update? do
    it "permits admin" do
      expect(subject).to permit(admin, estimate_item)
    end

    it "permits sales_manager" do
      expect(subject).to permit(sales_manager, estimate_item)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, estimate_item)
    end
  end

  permissions :destroy? do
    it "permits admin" do
      expect(subject).to permit(admin, estimate_item)
    end

    it "permits sales_manager" do
      expect(subject).to permit(sales_manager, estimate_item)
    end

    it "forbids executor" do
      expect(subject).not_to permit(executor, estimate_item)
    end
  end
end
