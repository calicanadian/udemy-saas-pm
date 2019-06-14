Rails.application.routes.draw do

  resources :members
  get 'home/index'
  root :to => "home#index"

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
