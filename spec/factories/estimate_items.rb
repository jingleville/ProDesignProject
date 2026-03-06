FactoryBot.define do
  factory :estimate_item do
    sequence(:name) { |n| "Item #{n}" }
    quantity { 2 }
    unit_price { 1500.0 }
    association :project

    trait :expensive do
      quantity { 10 }
      unit_price { 50_000.0 }
    end

    trait :single_unit do
      quantity { 1 }
    end
  end
end
