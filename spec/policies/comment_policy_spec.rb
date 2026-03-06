require "rails_helper"

RSpec.describe CommentPolicy, type: :policy do
  subject { described_class }

  let(:admin)           { build(:user, :admin) }
  let(:project_manager) { build(:user, :project_manager) }
  let(:production_head) { build(:user, :production_head) }
  let(:executor)        { build(:user, :executor) }
  let(:other_executor)  { build(:user, :executor) }

  let(:task)    { build(:task) }
  let(:comment) { build(:comment, task: task, user: executor) }

  permissions :index? do
    it "permits admin" do
      expect(subject).to permit(admin, comment)
    end

    it "permits project_manager" do
      expect(subject).to permit(project_manager, comment)
    end

    it "permits production_head" do
      expect(subject).to permit(production_head, comment)
    end

    it "permits executor" do
      expect(subject).to permit(executor, comment)
    end
  end

  permissions :create? do
    it "permits executor to comment on a task" do
      expect(subject).to permit(executor, comment)
    end

    it "permits project_manager" do
      expect(subject).to permit(project_manager, comment)
    end

    it "permits production_head" do
      expect(subject).to permit(production_head, comment)
    end
  end

  permissions :update? do
    it "permits the comment author to edit" do
      expect(subject).to permit(executor, comment)
    end

    it "permits admin to edit any comment" do
      expect(subject).to permit(admin, comment)
    end

    it "forbids another user from editing someone else's comment" do
      expect(subject).not_to permit(other_executor, comment)
    end

    it "forbids project_manager from editing executor's comment" do
      expect(subject).not_to permit(project_manager, comment)
    end
  end

  permissions :destroy? do
    it "permits the comment author to delete their own comment" do
      expect(subject).to permit(executor, comment)
    end

    it "permits admin to delete any comment" do
      expect(subject).to permit(admin, comment)
    end

    it "forbids another executor from deleting someone else's comment" do
      expect(subject).not_to permit(other_executor, comment)
    end
  end
end
