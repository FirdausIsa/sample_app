Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    get 'home/index'
    resources :posts
    root 'static_pages#home', as: "home" 
    get 'static_pages/help', as: "help"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  end
end
