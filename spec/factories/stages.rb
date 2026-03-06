FactoryBot.define do
  factory :stage do
    sequence(:name) { |n| "Stage #{n}" }
    sequence(:position) { |n| n }
    association :project

    trait :first do
      position { 1 }
    end

    trait :with_tasks do
      after(:create) do |stage|
        create_list(:task, 2, stage: stage, project: stage.project)
      end
    end
  end
end
