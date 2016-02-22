Rails.application.routes.draw do

  get 'about'    => 'api/dstutwo/fhir#about'
  get 'contact'    => 'api/dstutwo/fhir#contact'
  get 'home'    => 'api/dstutwo/fhir#splashpage'
  get 'exampleread'    => 'api/dstutwo/fhir#example_read'
  get 'examplecreate'    => 'api/dstutwo/fhir#example_create'
  get 'examplesearch'    => 'api/dstutwo/fhir#example_search'
  match '*any' => 'application#options', :via => [:options]
  match '/:resource_type/:id', to: 'api/dstutwo/fhir#read', via: :get
  match '/metadata', to: 'api/dstutwo/fhir#conformance', via: :get
  match '/:resource_type', to: 'api/dstutwo/fhir#search', via: :get
  match '/:resource_type', to: 'api/dstutwo/fhir#create', via: :post
  match '/:resource_type/:id', to: 'api/dstutwo/fhir#delete', via: :delete
  match '/:resource_type/:id', to: 'api/dstutwo/fhir#update', via: :put
  match '/:resource_type/:id/_history/:vid', to: 'api/dstutwo/fhir#vread', via: :get
  match '/:resource_type/:id/_history', to: 'api/dstutwo/fhir#history', via: :get  
  match '/', to: 'api/dstutwo/fhir#splashpage', via: :get

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
