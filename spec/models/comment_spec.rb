require "rails_helper"

RSpec.describe Comment, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to belong_to(:user) }
  end

  describe "mentions" do
    it "has a mentions attribute that is an array" do
      comment = build(:comment, mentions: [1, 2, 3])
      expect(comment.mentions).to eq([1, 2, 3])
    end

    it "defaults mentions to empty array" do
      comment = build(:comment)
      expect(comment.mentions).to eq([])
    end

    it "stores user IDs as mentions" do
      user1 = create(:user)
      user2 = create(:user)
      task = create(:task)
      comment = create(:comment, task: task, mentions: [user1.id, user2.id])

      expect(comment.reload.mentions).to contain_exactly(user1.id, user2.id)
    end
  end

  describe "not polymorphic" do
    it "belongs directly to task, not via polymorphic commentable" do
      assoc = Comment.reflect_on_association(:task)
      expect(assoc).not_to be_nil
      expect(assoc.macro).to eq(:belongs_to)
    end

    it "does not have a commentable polymorphic association" do
      assoc = Comment.reflect_on_association(:commentable)
      expect(assoc).to be_nil
    end
  end

  describe "#mentioned_users" do
    it "returns User records for each mention ID" do
      user1 = create(:user)
      user2 = create(:user)
      comment = create(:comment, mentions: [user1.id, user2.id])

      expect(comment.mentioned_users).to contain_exactly(user1, user2)
    end

    it "returns empty relation when no mentions" do
      comment = create(:comment, mentions: [])
      expect(comment.mentioned_users).to be_empty
    end
  end
end
