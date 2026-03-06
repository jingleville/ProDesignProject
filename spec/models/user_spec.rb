require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "associations" do
    it { is_expected.to have_many(:created_projects).class_name("Project") }
    it { is_expected.to have_many(:created_tasks).class_name("Task") }
    it { is_expected.to have_many(:assigned_tasks).class_name("Task") }
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:notifications) }
  end

  describe "roles" do
    it "defines all expected roles" do
      expect(User.roles.keys).to include(
        "sales_manager",
        "project_manager",
        "production_head",
        "executor",
        "director",
        "admin"
      )
    end

    it "does not include legacy worker role" do
      expect(User.roles.keys).not_to include("worker")
    end

    it "does not include legacy production_manager role" do
      expect(User.roles.keys).not_to include("production_manager")
    end
  end

  describe "role predicates" do
    it "identifies executor role" do
      user = build(:user, :executor)
      expect(user).to be_executor
    end

    it "identifies production_head role" do
      user = build(:user, :production_head)
      expect(user).to be_production_head
    end

    it "identifies sales_manager role" do
      user = build(:user, :sales_manager)
      expect(user).to be_sales_manager
    end

    it "identifies project_manager role" do
      user = build(:user, :project_manager)
      expect(user).to be_project_manager
    end
  end

  describe "#full_name" do
    it "returns concatenated first and last name" do
      user = build(:user, first_name: "Anna", last_name: "Ivanova")
      expect(user.full_name).to eq("Anna Ivanova")
    end
  end

  describe "#is_admin?" do
    it "returns true for admin role" do
      user = build(:user, :admin)
      expect(user.is_admin?).to be true
    end

    it "returns true for director role" do
      user = build(:user, :director)
      expect(user.is_admin?).to be true
    end

    it "returns false for executor role" do
      user = build(:user, :executor)
      expect(user.is_admin?).to be false
    end
  end

  describe ".executors" do
    it "returns only executor-role users" do
      executor = create(:user, :executor)
      head = create(:user, :production_head)
      manager = create(:user, :project_manager)

      result = User.executors
      expect(result).to include(executor)
      expect(result).not_to include(manager)
    end
  end
end
