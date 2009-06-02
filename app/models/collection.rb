class Collection < ActiveRecord::Base
  has_many :collection_albums
  has_many :albums, :through => :collection_albums

end
