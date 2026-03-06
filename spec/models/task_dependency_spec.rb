require "rails_helper"

RSpec.describe TaskDependency, type: :model do
  subject { create(:task_dependency) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:dependency_type) }
    it { is_expected.to validate_uniqueness_of(:depends_on_task_id).scoped_to(:task_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to belong_to(:depends_on_task).class_name("Task") }
  end

  describe "dependency_type enum" do
    it "defines all expected dependency types" do
      expect(TaskDependency.dependency_types.keys).to contain_exactly(
        "finish_to_start",
        "start_to_start",
        "finish_to_finish",
        "start_to_finish"
      )
    end
  end

  describe "dependency type predicates" do
    it "recognizes finish_to_start" do
      dep = build(:task_dependency, :finish_to_start)
      expect(dep).to be_finish_to_start
    end

    it "recognizes start_to_start" do
      dep = build(:task_dependency, :start_to_start)
      expect(dep).to be_start_to_start
    end

    it "recognizes finish_to_finish" do
      dep = build(:task_dependency, :finish_to_finish)
      expect(dep).to be_finish_to_finish
    end

    it "recognizes start_to_finish" do
      dep = build(:task_dependency, :start_to_finish)
      expect(dep).to be_start_to_finish
    end
  end

  describe "self-dependency validation" do
    it "prevents a task from depending on itself" do
      project = create(:project)
      task = create(:task, project: project)
      dep = build(:task_dependency, task: task, depends_on_task: task)

      expect(dep).not_to be_valid
      expect(dep.errors[:depends_on_task_id]).to be_present
    end
  end

  describe "circular dependency validation" do
    it "prevents circular dependencies" do
      project = create(:project)
      task_a = create(:task, project: project)
      task_b = create(:task, project: project)
      create(:task_dependency, task: task_a, depends_on_task: task_b)

      circular = build(:task_dependency, task: task_b, depends_on_task: task_a)
      expect(circular).not_to be_valid
    end
  end
end
