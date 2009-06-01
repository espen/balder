class Album < ActiveRecord::Base
  has_many :photos, :dependent => :destroy

  validates_uniqueness_of :path, :message => "Album already exsists on disc"

  before_validation :ensure_path
  after_create :create_folders
  before_destroy :destroy_directory

  attr_accessor :tag_list
  attr_protected :path
  
  protected
  
  def ensure_path
    self.path = self.title if !self.path
  end
  
  def tag_list
    tags = Array.new
    self.photos.map{ |photo|
        if photo.tags.empty?
          return
        else
          photo.tags
        end }.each_with_index{ |tag,i|
          puts tag.inspect
            tag.each { |t|
              puts t.title
              puts i
            if i == 0
              tags.push(t.title)
            elsif !tags.include?(t.title)
              tags.delete(t.title)
            end
          }
        }
    return tags.join(" ")
  end

  def tag_list=(tags)
    return if tags == self.tag_list
    
    #TODO HERE!
    ts = Array.new
    tags.split(" ").each do |tag|
      ts.push( Tag.find_or_create_by_title( :title => tag) )
    end
    self.tags = ts
  end  
  private
  
  def create_folders
    Dir.mkdir( APP_CONFIG[:photos_path] + self.path )
    Dir.mkdir( APP_CONFIG[:thumbs_path] + self.path ) 
  end
  
  def destroy_directory
    #puts "DELETE DIRECTORY " + APP_CONFIG[:photos_path] + self.path
    #Dir.delete( APP_CONFIG[:photos_path] + self.path + "/" ) if File.exists?( APP_CONFIG[:photos_path] + self.path )
    #Dir.delete( APP_CONFIG[:thumbs_path] + self.path  ) if File.exists?( APP_CONFIG[:thumbs_path] + self.path )
  end
end
