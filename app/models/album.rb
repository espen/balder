class Album < ActiveRecord::Base
  has_many :photos, :dependent => :destroy
  has_many :collection_albums
  has_many :collections, :through => :collection_albums

  validates_uniqueness_of :path, :message => "Album already exsists on disc"
  validates_presence_of :title, :message => "can't be blank"
  
  before_validation :ensure_path, :set_title
  after_create :create_folders
  after_destroy :destroy_folders

  attr_accessor :tag_list
  attr_protected :path
  
  named_scope :untouched, :conditions => "Albums.Id IN ( SELECT DISTINCT Photos.Album_Id FROM Photos WHERE Photos.description IS NULL AND Photos.Id NOT IN ( SELECT Photo_ID FROM Photo_Tags) )"

  def to_param
    "#{id}-#{title.parameterize}"
    #self.title.gsub(/[^a-z0-9]+/i, '-')
  end

  
  
  def ensure_path
    self.path = self.title unless self.path
  end
  
  def set_title
    self.title = File.basename( File.dirname(self.path) ) unless self.title || !self.path
  end
  
  def tag_list
    # should maybe cache this to database?
    # should maybe return array instead?
    
    tags = Array.new
    self.photos.map{ |photo|
        if photo.tags.empty?
          # photo has no tags => no unversial tags for this album
          return
        else
          photo.tags
        end
    }.each_with_index{ |photo_tags,i|
        # returns tag collection for each photo
        if i == 0
          tags = photo_tags
        else
          # combine arrays if they have identical tags.
          # Will remove tags that are only tagged to one photo
          tags = tags & photo_tags
        end
    }
    return tags.collect{|tag| tag.title }.sort.join(" ")
  end
  
  def tag_list=(tags)
    return if tags.split(" ").sort.join(" ") == self.tag_list
    current_tags = ( self.tag_list.nil? ? [] : self.tag_list.split(" ") )
    tags = tags.split(" ")
    
    # find tags that should be removed from this album - thus remove from all photos in album
    # i.e. tags listed in self.tag_list but no in parameter tags
    #current_tags.map {|tag|tag if !tags.include?(tag) }.compact
    (current_tags - tags).each { |tag|
      #puts "remove #{tag}"
      self.photos.each {|photo|
        photo.untag( tag )
      }
    }

    # add universial tags to all photos in album
    tags.each do |tag|
      #puts "tag photos with #{tag}" if !current_tags.include?( tag )
      self.photos.each { |photo|
        photo.tag( tag ) if !current_tags.include?( tag ) # no need to re-tag
      }
    end
  end
  protected

  private
  
  def create_folders
    Dir.mkdir( APP_CONFIG[:photos_path] + self.path ) unless File.exists?( APP_CONFIG[:photos_path] + self.path )
    Dir.mkdir( APP_CONFIG[:thumbs_path] + self.path ) unless File.exists?( APP_CONFIG[:thumbs_path] + self.path ) 
  end
  
  def destroy_folders
    #puts "DELETE DIRECTORY " + APP_CONFIG[:photos_path] + self.path
    Dir.delete( APP_CONFIG[:photos_path] + self.path ) if File.exists?( APP_CONFIG[:photos_path] + self.path )
    Dir.delete( APP_CONFIG[:thumbs_path] + self.path  ) if File.exists?( APP_CONFIG[:thumbs_path] + self.path )
  end
end
