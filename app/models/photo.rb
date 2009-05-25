class Photo < ActiveRecord::Base
  belongs_to :album
  has_many :photo_tags, :dependent => :destroy
  has_many :tags, :through => :photo_tags
  
  #accepts_nested_attributes_for :photo_tags, :allow_destroy => true
  
  validates_uniqueness_of :path, :message => "Photo already exsists on disc"
  validates_presence_of :title
  
  before_destroy :destroy_file
  
  attr_accessor :tag_list
  
  def tag_list
    return self.tags.find(:all, :order => 'title').collect{ |t| t.title }.join(" ")
  end

  def tag_list=(tags)
    ts = Array.new
    tags.split(" ").each do |tag|
      ts.push( Tag.find_or_create_by_title( :title => tag) )
    end
    self.tags = ts
  end
  
  private
  
  
  def destroy_file
    puts "DELETE FILE " + APP_CONFIG[:photos_path] + self.path
    File.delete( APP_CONFIG[:photos_path] + self.path  ) if File.exists?( APP_CONFIG[:photos_path] + self.path )
    File.delete( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_small" + File.extname( APP_CONFIG[:photos_path] + self.path ) ) if File.exists?( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_small" + File.extname( APP_CONFIG[:photos_path] + self.path ) )
    File.delete( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_large" + File.extname( APP_CONFIG[:photos_path] + self.path ) ) if File.exists?( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_large" + File.extname( APP_CONFIG[:photos_path] + self.path ) )
  end
end
