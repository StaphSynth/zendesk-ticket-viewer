Rails.application.routes.draw do
  get 'react_tickets', to: 'react#index'
  get 'react_ticket', to: 'react#show'
  root to: redirect('/tickets')
  resources :tickets, only: [:index, :show]
end
