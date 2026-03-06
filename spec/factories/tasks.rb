FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    description { "A test task" }
    status { :draft }
    association :project
    association :created_by, factory: :user

    trait :draft do
      status { :draft }
    end

    trait :awaiting_approval do
      status { :awaiting_approval }
    end

    trait :approved do
      status { :approved }
      approved_at { Time.current }
      association :approved_by, factory: :user
    end

    trait :in_progress do
      status { :in_progress }
      actual_start_at { 1.day.ago }
    end

    trait :pending_confirmation do
      status { :pending_confirmation }
      actual_start_at { 2.days.ago }
      actual_due_at { Time.current }
    end

    trait :completed do
      status { :completed }
      actual_start_at { 3.days.ago }
      actual_due_at { 1.day.ago }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :with_plan_dates do
      plan_start_at { Date.current }
      plan_due_at { 7.days.from_now }
    end

    trait :with_approved_dates do
      approved_start_at { Date.current }
      approved_due_at { 5.days.from_now }
    end

    trait :overdue do
      plan_due_at { 3.days.ago }
      approved_due_at { nil }
    end
  end
end
