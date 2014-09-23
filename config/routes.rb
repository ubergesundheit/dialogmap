Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'page#index'
  get 'wirmachenmit', to: 'page#wirmachenmit'
  devise_for :users, path: "api/users", defaults: { format: :json }, :controllers => { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations' }, skip: [:confirmations]

  as :user do
    get   '/users/confirm', to: 'confirmations#show',   as: 'user_confirmation'
    post  '/users/confirm', to: 'confirmations#create'
    get   '/users/confirm/resend', to: 'confirmations#new',    as: 'new_user_confirmation'
  end

  namespace :api, defaults: { format: :json } do
    get 'contributions/filter_items', to: 'contributions#filter_items'
    get 'contributions/categories', to: 'contributions#categories'
    get 'contributions/activities', to: 'contributions#activities'
    get 'contributions/contents', to: 'contributions#contents'
    resources :contributions
    post 'contributions/:id/toggle_favorite', to: 'contributions#toggle_favorite', as: 'contribution_toggle_favorite'
  end

  match '/finish_signup/:id' => 'users#finish_signup', via: [:get, :patch], as: :finish_signup

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
