class Photo < ActiveRecord::Base
  belongs_to :album
  
  validates_uniqueness_of :path, :message => "Photo already exsists on disc"
end
