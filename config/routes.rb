Jazzhouston::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

root :to => 'home#index'

match 'home/mobile' => 'home#mobile'
#resources :releases
match 'venues/search_ext' => 'venues#search_ext'
resources :venues
match 'articles/words/:id' => 'articles#words'
match 'articles/reviews' => 'articles#reviews'
match 'articles/artists' => 'articles#artists'
match 'articles/opinions' => 'articles#opinions'
match 'articles/articles' => 'articles#articles'
match 'articles/rss' => 'articles#rss'
match 'articles/workflow' => 'articles#workflow'
match 'articles/search_articles_url_ext' => 'articles#search_articles_url_ext'
match 'news' => 'articles#index'
match 'news/reviews' => 'articles#reviews'
resources :articles
match 'events/:year/:month/:day' => 'events#day'
#resources :events

match 'forums' => 'forums#index', :via => :get
match 'forum' => 'forums#index'

match 'forums/new' => 'forums#new'
match 'forums' => 'forums#create', :via => :post
match 'forums/vote' => 'forums#vote', :format => false  , :via => :get

#match 'forums/messages' => 'forums#update', :via => :post

match 'members/challenge_image'  => 'members#challenge_image'
match 'members/logout'  => 'members#logout'
match 'members/login'  => 'members#login'
match 'members/vcard/:id'  =>'musicians#vcard'
match 'members/confirm/:username/:key'  => 'members#confirm', :constraints  => { :username => /[0-z\.]+/ }
match 'members/resetpassword/:username/:key'  => 'members#resetpassword'

match '/:controller(/:action(/:id))'


end
