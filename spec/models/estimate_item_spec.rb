require "rails_helper"

RSpec.describe EstimateItem, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:unit_price) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:project) }
  end

  describe "#total_price" do
    it "computes total as quantity times unit_price" do
      item = build(:estimate_item, quantity: 3, unit_price: 1000.0)
      expect(item.total_price).to eq(3000.0)
    end

    it "returns 0 when quantity is 0" do
      item = build(:estimate_item, quantity: 0, unit_price: 500.0)
      expect(item.total_price).to eq(0)
    end
  end

  describe "project budget totals" do
    it "sums all estimate items for a project" do
      project = create(:project)
      create(:estimate_item, project: project, quantity: 2, unit_price: 1000.0)
      create(:estimate_item, project: project, quantity: 1, unit_price: 3000.0)

      total = project.estimate_items.sum { |i| i.total_price }
      expect(total).to eq(5000.0)
    end
  end

  describe "not associated to tasks" do
    it "belongs to project, not task" do
      expect(EstimateItem.reflect_on_association(:task)).to be_nil
    end
  end
end
