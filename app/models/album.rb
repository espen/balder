class Album < ActiveRecord::Base
  has_many :photos, :dependent => :destroy
  has_many :collection_albums
  has_many :collections, :through => :collection_albums

  validates :path, :presence => true, :uniqueness => true #, :message => "Album already exsists on disc"
  validates :title, :presence => true #, :message => "can't be blank"
  
  before_validation :ensure_path, :set_title
  after_create :create_folders
  after_destroy :destroy_folders

  attr_accessor :tags
  #attr_protected :path
  
  scope :untouched, where("albums.id IN ( SELECT DISTINCT photos.album_id FROM photos WHERE photos.description IS NULL AND photos.id NOT IN ( SELECT photo_id FROM photo_tags) )").order('title')
  scope :unused, where("albums.id NOT IN (SELECT album_id FROM collection_albums)")
  scope :used, where("albums.id IN (SELECT album_id FROM collection_albums)")

  def to_param
    "#{id}-#{title.parameterize}"
  end
  
  def ensure_path
    self.path = self.title.parameterize unless self.path
  end
  
  def set_title
    self.title = File.basename(self.path).titleize unless self.title || !self.path
  end
  
  def tags
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
          #tags = tags & photo_tags
          tags = tags & photo_tags
        end
    }
    return tags
  end
  
  def tags=(tags)
    tags = tags.split(" ").sort
    current_tags = ( self.tags.nil? ? [] : self.tags.map{|tag|tag.title} )
    return if tags == self.tags
    
    # find tags that should be removed from this album - thus remove from all photos in album
    # i.e. tags listed in self.tag_list but no in parameter tags
    #current_tags.map {|tag|tag if !tags.include?(tag) }.compact
    (current_tags - tags).each { |tag|
      self.photos.each {|photo|
        photo.untag( tag )
      }
    }

    # add universial tags to all photos in album
    (tags - current_tags).each do |tag|
      self.photos.each { |photo|
        photo.tag( tag )
      }
    end
  end

  def photo_tags
    tags = Array.new
    self.photos.each{ |photo|
      tags = tags | photo.tags
    }
    return tags
   end

  protected

  private
  
  def create_folders
    #Dir.mkdir( APP_CONFIG[:photos_path] + self.path ) unless File.exists?( APP_CONFIG[:photos_path] + self.path )
    #Dir.mkdir( APP_CONFIG[:thumbs_path] + self.path ) unless File.exists?( APP_CONFIG[:thumbs_path] + self.path )
  end
  
  def destroy_folders
    #puts "DELETE DIRECTORY " + APP_CONFIG[:photos_path] + self.path
    #Dir.delete( APP_CONFIG[:photos_path] + self.path ) if File.exists?( APP_CONFIG[:photos_path] + self.path )
    #Dir.delete( APP_CONFIG[:thumbs_path] + self.path  ) if File.exists?( APP_CONFIG[:thumbs_path] + self.path )
  end
end
