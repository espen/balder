class Album < ActiveRecord::Base
  has_many :photos, :dependent => :destroy
  
  validates_uniqueness_of :path, :message => "Album already exsists on disc"

  before_destroy :destroy_directory
  
  private
  
  def destroy_directory
    #puts "DELETE DIRECTORY " + APP_CONFIG[:photos_path] + self.path
    #Dir.delete( APP_CONFIG[:photos_path] + self.path + "/" ) if File.exists?( APP_CONFIG[:photos_path] + self.path )
    #Dir.delete( APP_CONFIG[:thumbs_path] + self.path  ) if File.exists?( APP_CONFIG[:thumbs_path] + self.path )
  end
end
