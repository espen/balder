class Collection < ActiveRecord::Base
  has_many :collection_albums
  has_many :albums, :through => :collection_albums

  def to_param
     title.gsub(/[^a-z0-9]+/i, '-')
  end

end