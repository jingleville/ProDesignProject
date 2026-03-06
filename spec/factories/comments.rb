FactoryBot.define do
  factory :comment do
    body { "This is a test comment." }
    mentions { [] }
    association :task
    association :user

    trait :with_mentions do
      transient do
        mentioned_users { create_list(:user, 2) }
      end
      after(:build) do |comment, evaluator|
        comment.mentions = evaluator.mentioned_users.map(&:id)
      end
    end

    trait :with_body do
      body { "Detailed comment with some context." }
    end
  end
end
