Rails.application.routes.draw do
  resources :user_projects
  resources :artifacts
  root :to => "home#index"

  get 'home/index'

  resources :tenants do
    resources :projects do
      get 'users', on: :member
      put 'add_user', on: :member
    end
  end

  resources :members
  # *MUST* come *BEFORE* devise's definitions (below)
  as :user do
    match '/user/confirmation' => 'confirmations#update', :via => :put, :as => :update_user_confirmation # override controller
  end

  devise_for :users, :controllers => {
    :registrations => "registrations",
    :confirmations => "confirmations", #override controller
    :sessions => "milia/sessions",
    :passwords => "milia/passwords",
  }

  match '/plan/edit' => 'tenants#edit', via: :get, as: :edit_plan
  match '/plan/update' => 'tenants#update', via: [:put, :patch], as: :update_plan

end
