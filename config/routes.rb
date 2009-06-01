ActionController::Routing::Routes.draw do |map|
  #map.resources :users
  map.resource :user_session
  map.resource :account, :controller => "users"
  map.signup "signup", :controller => "users", :action => "new"
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  map.resources :photos, :collection => { :untouched => :get }
  map.resources :albums, :has_many => [ :photos ], :collection => { :untouched => :get }, :member => { :upload => :get}
  map.resources :tags, :has_many => [ :photos ]
  
	map.namespace :admin do |admin|
    admin.resources :users
  end
  
  map.root :controller => "albums"

end
