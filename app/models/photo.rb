class Photo < ActiveRecord::Base
  belongs_to :album
  has_many :photo_tags, :dependent => :destroy
  has_many :tags, :through => :photo_tags
  
  validates_uniqueness_of :path, :message => "Photo already exsists on disc"
  
  before_destroy :destroy_file
  
  private
  
  def destroy_file
    puts "DELETE FILE " + APP_CONFIG[:photos_path] + self.path
    File.delete( APP_CONFIG[:photos_path] + self.path  ) if File.exists?( APP_CONFIG[:photos_path] + self.path )
    File.delete( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_small" + File.extname( APP_CONFIG[:photos_path] + self.path ) ) if File.exists?( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_small" + File.extname( APP_CONFIG[:photos_path] + self.path ) )
    File.delete( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_large" + File.extname( APP_CONFIG[:photos_path] + self.path ) ) if File.exists?( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_large" + File.extname( APP_CONFIG[:photos_path] + self.path ) )
  end
end
