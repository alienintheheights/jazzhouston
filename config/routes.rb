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

#TODO clean this up, best RESTful etc
root :to => 'home#index'

devise_for :users,
             :controllers => { :registrations => "devise/registrations",
                               :confirmations => "devise/confirmations",
                               :sessions => 'devise/sessions',
                               :passwords => 'passwords'},
             :skip => [:sessions] do
    get '/login'   => "devise/sessions#new",       :as => :new_user_session
    post '/login'  => 'devise/sessions#create',    :as => :user_session
    get '/logout'  => 'devise/sessions#destroy',   :as => :destroy_user_session
    get "/register"   => "devise/registrations#new",   :as => :new_user_registration
end

#devise_for :users do get '/users/sign_out' => 'devise/sessions#destroy' end
 # resources :users

=begin

devise_for :users, path: "auth", path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    password: 'secret',
    confirmation: 'verification',
    unlock: 'unblock',
    registration: 'register',
    sign_up: 'cmon_let_me_in' }

devise_scope :user do
  get "sign_in", to: "devise/sessions#new"
  get '/users/sign_out' => 'devise/sessions#destroy'
end
=end

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

#match 'users/:id' => 'members#profile', via: :get

match 'members/challenge_image'  => 'members#challenge_image'

match '/:controller(/:action(/:id))'


end
