Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  resources :projects do
    resources :tasks do
      member do
        patch :submit_for_approval
        patch :approve
        patch :reject
        patch :start
        patch :complete
        patch :assign
      end
      resources :comments, only: [ :create, :destroy ], module: :tasks
      resources :budget_items, only: [ :create, :update, :destroy ]
    end
    resources :comments, only: [ :create, :destroy ], module: :projects
    get :gantt, on: :member
  end

  namespace :admin do
    resources :users, only: [ :index, :edit, :update ]
  end

  get "planner/calendar", to: "planner#calendar", as: :planner_calendar
  get "planner", to: "planner#index"
  get "production", to: "production#index"
  get "gantt", to: "gantt#index"

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "projects#index"
end
