Rails.application.routes.draw do
  root :to => "home#index"

  get 'home/index'

  resources :tenants do
    resources :projects
  end
  
  resources :members
  # *MUST* come *BEFORE* devise's definitions (below)
  as :user do
    match '/user/confirmation' => 'confirmations#update', :via => :put, :as => :update_user_confirmation # override controller
  end

  devise_for :users, :controllers => {
    :registrations => "milia/registrations",
    :confirmations => "confirmations", #override controller
    :sessions => "milia/sessions",
    :passwords => "milia/passwords",
  }


end
