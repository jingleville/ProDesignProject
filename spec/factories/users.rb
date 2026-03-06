FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    first_name { "Ivan" }
    last_name { "Petrov" }
    role { :executor }

    trait :sales_manager do
      role { :sales_manager }
    end

    trait :project_manager do
      role { :project_manager }
    end

    trait :production_head do
      role { :production_head }
    end

    trait :executor do
      role { :executor }
    end

    trait :director do
      role { :director }
    end

    trait :admin do
      role { :admin }
    end
  end
end
