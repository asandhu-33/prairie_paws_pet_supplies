Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users, controllers: { sessions: "users/sessions" }

  root "home#index"
  resources :products, only: %i[index show]

  resource :cart, only: %i[show] do
    post "add/:product_id", to: "carts#add", as: :add_item
    patch "update_item/:product_id", to: "carts#update_item", as: :update_item
    delete "remove_item/:product_id", to: "carts#remove_item", as: :remove_item
    delete "clear", to: "carts#clear", as: :clear
  end

  resource :checkout, only: %i[show create]
  resources :orders, only: %i[index show]

  get "/about", to: "pages#show", defaults: { slug: "about" }, as: :about
  get "/contact", to: "pages#show", defaults: { slug: "contact" }, as: :contact
end