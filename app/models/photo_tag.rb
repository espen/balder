class PhotoTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :photo
end
