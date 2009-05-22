ActionController::Routing::Routes.draw do |map|
  map.resources :photos
  map.resources :albums
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
