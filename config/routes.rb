Rails.application.routes.draw do
  resources :posts do
    member do
      get 'show_target_image', to: 'posts#show_target_image'
      get 'show_with_restriction', to: 'posts#show_with_restriction'
      get 'show_with_restriction_for_canny_min', to: 'show_with_restriction_for_canny_min'
      get 'show_with_restriction_for_canny_max', to: 'show_with_restriction_for_canny_max'
    end
  end
  devise_for:users
  root 'posts#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.ht    ml
  resources :users, only: [:index] do
    member do
      get "make_friendship", to: "users#make_friendship"
      get "accept_friendship", to: "users#accept_friendship"
      get "decline_friendship", to: "users#decline_friendship"
      delete "remove_friendship", to: "users#remove_friendship"
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
