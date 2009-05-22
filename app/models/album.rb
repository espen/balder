class Album < ActiveRecord::Base
  has_many :photos
  
  validates_uniqueness_of :path, :message => "Album already exsists on disc"
  
end
