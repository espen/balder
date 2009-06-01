require "image_science"
require 'mini_exiftool'

class Photo < ActiveRecord::Base
  belongs_to :album
  has_many :photo_tags, :dependent => :destroy
  has_many :tags, :through => :photo_tags
  
  validates_uniqueness_of :path, :message => "Photo already exsists on disc"
  validates_presence_of :title
  
  before_create :create_thumbnails, :read_exif
  before_destroy :destroy_file

  attr_accessor :tag_list
  attr_protected :path


  def self.untouched
    self.find(:all, :conditions => "Photos.description IS NULL AND Photos.Id NOT IN ( SELECT Photo_ID FROM Photo_Tags)", :include => :album )
  end
  
  def path_original
    return APP_CONFIG[:photos_path] + self.path
  end
  
  def path_original_public
    return APP_CONFIG[:photos_path_public] + self.path
  end

  def path_modified(size)
    return APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_" + size + ".jpg"
  end

  def path_modified_public(size)
    return APP_CONFIG[:thumbs_path_public] + self.album.path + "/" + self.id.to_s + "_" + size + ".jpg"
  end

  
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
  
  
  def create_thumbnails
    ImageScience.with_image(APP_CONFIG[:photos_path] + self.path) do |img|
        #puts "    thumbing it..thumbing it.."
        ext = File.extname( APP_CONFIG[:photos_path] + self.path )

        img.thumbnail(85) do |thumb|
          thumb.save APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_thumb" + ext
        end
        img.thumbnail(150) do |thumb|
          thumb.save APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_album" + ext
        end
        img.thumbnail(800) do |thumb|
          thumb.save APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_large" + ext
        end
    end
  end
  
  def read_exif
    photo = MiniExiftool.new(self.path_original)
    self.longitude = photo.GPSLongitude
    self.latitude = photo.GPSLatitude
    self.title = photo.DocumentName
    self.description = photo.ImageDescription
  end
  
  def write_exif
    photo = MiniExiftool.new(self.path_original)
    photo.GPSLongitude = self.longitude
    photo.GPSLatitude = self.latitude
    photo.DocumentName = self.title
    photo.ImageDescription = self.description
    photo.save
  end
  
  def exif_info
    photo = MiniExiftool.new(self.path_original)
    photo.tags.sort.each do |tag|
      puts tag.ljust(28) + photo[tag].to_s
    end
  end

  # Map file extensions to mime types.
  # Thanks to bug in Flash 8 the content type is always set to application/octet-stream.
  # From: http://blog.airbladesoftware.com/2007/8/8/uploading-files-with-swfupload
  def swf_uploaded_data=(data)
    data.content_type = MIME::Types.type_for(data.original_filename)
    self.title = data.original_filename
    self.path = self.album.path + "/" + data.original_filename
    File.open(APP_CONFIG[:photos_path] + self.path, "wb") { |f| f.write(data.read) }
  end

  
  private
  
  
  def destroy_file
    #puts "DELETE THUMBS OF " + APP_CONFIG[:photos_path] + self.path
    #File.delete( APP_CONFIG[:photos_path] + self.path  ) if File.exists?( APP_CONFIG[:photos_path] + self.path )
    File.delete( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_thumb" + File.extname( APP_CONFIG[:photos_path] + self.path ) ) if File.exists?( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_small" + File.extname( APP_CONFIG[:photos_path] + self.path ) )
    File.delete( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_album" + File.extname( APP_CONFIG[:photos_path] + self.path ) ) if File.exists?( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_small" + File.extname( APP_CONFIG[:photos_path] + self.path ) )
    File.delete( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_large" + File.extname( APP_CONFIG[:photos_path] + self.path ) ) if File.exists?( APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_large" + File.extname( APP_CONFIG[:photos_path] + self.path ) )
  end
end
