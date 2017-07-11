Rails.application.routes.draw do
  root 'tickets#index'
  get '/ticket', to: 'tickets#show'
end
