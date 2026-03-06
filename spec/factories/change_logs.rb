FactoryBot.define do
  factory :change_log do
    entity_type { "Task" }
    entity_id { 1 }
    field_name { "status" }
    old_value { "draft" }
    new_value { "awaiting_approval" }
    changed_at { Time.current }
    association :changed_by, factory: :user

    trait :for_project do
      entity_type { "Project" }
      field_name { "status" }
      old_value { "draft" }
      new_value { "active" }
    end

    trait :status_change do
      field_name { "status" }
    end

    trait :date_change do
      field_name { "plan_due_at" }
      old_value { 2.days.ago.to_s }
      new_value { 5.days.from_now.to_s }
    end
  end
end
