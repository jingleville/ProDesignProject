require "rails_helper"

RSpec.describe Stage, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_numericality_of(:position).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:tasks).dependent(:nullify) }
  end

  describe "ordering" do
    it "can be ordered by position" do
      project = create(:project)
      stage_b = create(:stage, project: project, position: 2, name: "Stage B")
      stage_a = create(:stage, project: project, position: 1, name: "Stage A")

      expect(Stage.order(:position).first).to eq(stage_a)
      expect(Stage.order(:position).last).to eq(stage_b)
    end
  end

  describe "uniqueness within project" do
    it "does not allow duplicate positions in the same project" do
      project = create(:project)
      create(:stage, project: project, position: 1)
      duplicate = build(:stage, project: project, position: 1)

      expect(duplicate).not_to be_valid
    end

    it "allows same position in different projects" do
      project1 = create(:project)
      project2 = create(:project)
      create(:stage, project: project1, position: 1)
      stage = build(:stage, project: project2, position: 1)

      expect(stage).to be_valid
    end
  end

  describe "#completion_percentage" do
    it "returns 0 when there are no tasks" do
      stage = create(:stage)
      expect(stage.completion_percentage).to eq(0)
    end

    it "returns 100 when all tasks are completed" do
      stage = create(:stage)
      project = stage.project
      create(:task, :completed, stage: stage, project: project)
      create(:task, :completed, stage: stage, project: project)

      expect(stage.completion_percentage).to eq(100)
    end

    it "returns percentage of completed tasks" do
      stage = create(:stage)
      project = stage.project
      create(:task, :completed, stage: stage, project: project)
      create(:task, :in_progress, stage: stage, project: project)

      expect(stage.completion_percentage).to eq(50)
    end
  end
end
