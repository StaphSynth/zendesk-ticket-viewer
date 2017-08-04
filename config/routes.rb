Rails.application.routes.draw do
  get 'test_react', to: 'test_react#index'
  root to: redirect('/tickets')
  resources :tickets, only: [:index, :show]
end
