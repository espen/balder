class Tag < ActiveRecord::Base
  has_many :photo_tags
  has_many :photos, :through => :photo_tags
  
  validates_uniqueness_of :title

  before_validation :downcase_title

  def self.tag_list
    return self.find(:all).map { |tag| tag.title }.join('\',\'')
  end

  def to_param
     #id.to_s+'-'+
     self.title.parameterize
     #title.downcase.gsub(/[^a-z0-9]+/i, '-')
   end

   protected

   def downcase_title
     self.title.downcase! if attribute_present?("title")
   end

end
