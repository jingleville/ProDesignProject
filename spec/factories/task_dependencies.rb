FactoryBot.define do
  factory :task_dependency do
    association :task
    association :depends_on_task, factory: :task
    dependency_type { :finish_to_start }

    trait :finish_to_start do
      dependency_type { :finish_to_start }
    end

    trait :start_to_start do
      dependency_type { :start_to_start }
    end

    trait :finish_to_finish do
      dependency_type { :finish_to_finish }
    end

    trait :start_to_finish do
      dependency_type { :start_to_finish }
    end
  end
end
