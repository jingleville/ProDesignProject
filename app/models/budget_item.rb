class BudgetItem < ApplicationRecord
  belongs_to :task
  validates :material, presence: true
  validates :quantity, :price, numericality: { greater_than_or_equal_to: 0 }

  def total
    quantity.to_f * price.to_f
  end
end
