class Collection < ActiveRecord::Base
  has_many :collection_albums
  has_many :albums, :through => :collection_albums
  #accepts_nested_attributes_for :albums, :allow_destroy => true
  attr_accessor :album_list

  def to_param
     title.gsub(/[^a-z0-9]+/i, '-')
  end

  def album_list=(albums)
    self.albums = Album.find(albums)
  end
  
  

end