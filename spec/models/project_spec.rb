require "rails_helper"

RSpec.describe Project, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:creator).class_name("User") }
    it { is_expected.to have_many(:stages).dependent(:destroy) }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to have_many(:estimate_items).dependent(:destroy) }
  end

  describe "statuses" do
    it "defines all expected statuses" do
      expect(Project.statuses.keys).to contain_exactly("draft", "active", "completed", "archived")
    end
  end

  describe "status predicates" do
    it "recognizes draft status" do
      project = build(:project, :draft)
      expect(project).to be_draft
    end

    it "recognizes active status" do
      project = build(:project, :active)
      expect(project).to be_active
    end

    it "recognizes completed status" do
      project = build(:project, :completed)
      expect(project).to be_completed
    end

    it "recognizes archived status" do
      project = build(:project, :archived)
      expect(project).to be_archived
    end
  end

  describe "#check_completion!" do
    let(:project) { create(:project, :active) }

    context "when all tasks are completed" do
      it "marks the project as completed" do
        create(:task, :completed, project: project)
        create(:task, :completed, project: project)

        project.check_completion!
        expect(project.reload).to be_completed
      end
    end

    context "when some tasks are not completed" do
      it "does not mark the project as completed" do
        create(:task, :completed, project: project)
        create(:task, :in_progress, project: project)

        project.check_completion!
        expect(project.reload).to be_active
      end
    end

    context "when project has no tasks" do
      it "does not mark the project as completed" do
        project.check_completion!
        expect(project.reload).to be_active
      end
    end
  end

  describe "stages ordering" do
    it "returns stages ordered by position" do
      project = create(:project)
      stage3 = create(:stage, project: project, position: 3)
      stage1 = create(:stage, project: project, position: 1)
      stage2 = create(:stage, project: project, position: 2)

      expect(project.stages.order(:position)).to eq([stage1, stage2, stage3])
    end
  end
end
