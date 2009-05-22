class Album < ActiveRecord::Base
  has_many :photos
end
