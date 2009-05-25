ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resource :user_session
  map.resource :account, :controller => "users"
  map.signup "signup", :controller => "users", :action => "new"
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"
  map.resources :photos
  map.resources :albums
  map.resources :tags, :has_many => [ :photos ]
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
  
  map.root :controller => "user_sessions", :action => "new" # optional, this just sets the root route

end
