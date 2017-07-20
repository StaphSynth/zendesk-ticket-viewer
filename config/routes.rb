Rails.application.routes.draw do
  root to: redirect('/tickets')
  resources :tickets, only: [:index, :show]
end
