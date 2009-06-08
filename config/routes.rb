ActionController::Routing::Routes.draw do |map|
  #map.resources :users
  map.resource :user_session
  map.resource :account, :controller => "users"
  map.signup "signup", :controller => "users", :action => "new"
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  map.resources :photos, :collection => { :untouched => :get }
  map.resources :albums, :collection => { :untouched => :get }, :member => { :upload => :get}, :has_many => [ :photos ]
  map.resources :collections
  map.resources :tags, :has_many => [ :photos, :albums ]
  
	map.namespace :admin do |admin|
    admin.resources :users
  end
  
  map.root :controller => "collections"

end
