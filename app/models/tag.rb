class Tag < ActiveRecord::Base
  has_many :photo_tags
  has_many :photos, :through => :photo_tags
  
  validates_uniqueness_of :title
  
  def self.tag_list
    return self.find(:all).map { |tag| tag.title }.join('\',\'')
  end

  def to_param
     #{ }"#{id}-#{name.gsub(/[^a-z0-9]+/i, '-')}"
     #id.to_s+'-'+name.downcase.gsub(/[^a-z0-9]+/i, '-')
     #id.to_s+'-'+name.downcase.gsub(' ', '-')
     self.title
   end

end
