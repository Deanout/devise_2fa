Rails.application.routes.draw do
  root 'pages#home'
  get 'pages/home'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  } do
  end

  get 'enable_otp_show_qr', to: 'users#enable_otp_show_qr', as: 'enable_otp_show_qr'
  post 'enable_otp_verify', to: 'users#enable_otp_verify', as: 'enable_otp_verify'

  get 'users/otp', to: 'users#show_otp', as: 'user_otp'
  post 'users/otp', to: 'users#verify_otp', as: 'verify_user_otp'
  post 'verify_otp', to: 'users/sessions#verify_otp'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
