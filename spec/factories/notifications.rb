FactoryBot.define do
  factory :notification do
    event_type { "task_assigned" }
    message { "You have been assigned a task." }
    data { {} }
    association :user
    association :actor, factory: :user

    trait :unread do
      read_at { nil }
    end

    trait :read do
      read_at { 1.hour.ago }
    end

    trait :task_assigned do
      event_type { "task_assigned" }
      message { "Task has been assigned to you." }
      data { { task_id: 1, task_title: "Test Task" } }
    end

    trait :task_approved do
      event_type { "task_approved" }
      message { "Your task has been approved." }
      data { { task_id: 1, approved_by: "Manager" } }
    end

    trait :with_notifiable do
      association :notifiable, factory: :task
    end
  end
end
