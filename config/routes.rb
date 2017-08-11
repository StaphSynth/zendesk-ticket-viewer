Rails.application.routes.draw do
  get 'react_tickets', to: 'react#index'
  root to: redirect('/tickets')
  resources :tickets, only: [:index, :show]
end
