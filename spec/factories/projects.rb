FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { "A test project" }
    status { :draft }
    association :creator, factory: :user

    trait :draft do
      status { :draft }
    end

    trait :active do
      status { :active }
    end

    trait :completed do
      status { :completed }
    end

    trait :archived do
      status { :archived }
    end
  end
end
