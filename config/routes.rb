Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users

  root "home#index"
  resources :products, only: %i[index show]

  get "/about", to: "pages#show", defaults: { slug: "about" }, as: :about
  get "/contact", to: "pages#show", defaults: { slug: "contact" }, as: :contact
end