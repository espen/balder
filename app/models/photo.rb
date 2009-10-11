require "image_science"
require 'mini_exiftool'

class Photo < ActiveRecord::Base
  belongs_to :album
  has_many :photo_tags, :dependent => :destroy
  has_many :tags, :through => :photo_tags
  
  validates_uniqueness_of :path, :message => "Photo already exsists on disc"
  validates_presence_of :title
  
  before_validation :set_title
  before_save :ensure_file
  before_create :exif_read
  after_create :create_thumbnails
  #before_update :exif_write # should only write if tags are changed as images can be large and thus ExifTool will take a while to write to the file
  before_destroy :destroy_file

  attr_accessor :tag_list
  #attr_protected :path
  
  named_scope :untouched, :conditions => "photos.description IS NULL AND photos.id NOT IN ( SELECT photo_id FROM photo_tags)", :include => :album 
  named_scope :previous, lambda { |p,a| { :conditions => ["id < :id AND album_Id = :album ", { :id => p, :album => a } ], :limit => 1, :order => "id DESC"} }
  named_scope :next, lambda { |p,a| { :conditions => ["id > :id AND album_Id = :album ", { :id => p, :album => a } ], :limit => 1, :order => "id ASC"} }

  def to_param
    "#{id}-#{title.parameterize}"
  end
  
  def path_original_public
    return APP_CONFIG[:photos_path_public] + self.path
  end

  def path_modified_public(size)
    return APP_CONFIG[:thumbs_path_public] + self.album.path + "/" + self.id.to_s + "_" + size + self.extension
  end
  
  def tag(title)
    return if self.tags.collect{|tag|tag.title}.include?( title )
    self.photo_tags.create(:tag => Tag.find_or_create_by_title( :title => title) )
    self.reload
  end
  
  def untag(title)
    return if !self.tags.collect{|tag|tag.title}.include?( title )
    # perhaps not the best way but it finds the correct PhotoTag and deletes it
    self.photo_tags.select{|photo_tag|
      photo_tag.tag.title == title
    }.each {|photo_tag|photo_tag.destroy}
    self.reload
  end

  def tag_list
    return self.tags.find(:all, :order => 'title').map{ |t| t.title }.sort.join(" ")
  end

  def tag_list=(tags)
    ts = Array.new
    tags.split(" ").each do |tag|
      ts.push( Tag.find_or_create_by_title( :title => tag.downcase) )
    end
    self.tags = ts
  end
  
  
  def exif_info
    photo = MiniExiftool.new(self.path_original)
    #photo.tags.sort.each do |tag|
    #  puts tag.ljust(28) + photo[tag].to_s
    #end
  end

  # Map file extensions to mime types.
  # Thanks to bug in Flash 8 the content type is always set to application/octet-stream.
  # From: http://blog.airbladesoftware.com/2007/8/8/uploading-files-with-swfupload
  def swf_uploaded_data=(data)
    data.content_type = MIME::Types.type_for(data.original_filename)
    self.title = data.original_filename
    self.path = self.album.path + "/" + data.original_filename.parameterize
    File.open(APP_CONFIG[:photos_path] + self.path, 'wb') { |f| f.write(data.read) }
  end
  
  def create_thumbnails
    # TODO: thumbnails size should be set in settings.yml

    return if File.exists?(APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_collection" + self.extension)
    puts "thumb " + self.path_original
    ImageScience.with_image(self.path_original) do |img|
        img.cropped_thumbnail(200) do |thumb|
          thumb.save APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_collection" + self.extension
        end
        img.cropped_thumbnail(100) do |thumb|
          thumb.save APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_album" + self.extension
        end
        img.thumbnail(210) do |thumb|
          thumb.save APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_preview" + self.extension
        end
        img.thumbnail(950) do |thumb|
          thumb.save APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_single" + self.extension
        end
    end
  end

  protected

  def extension
    return File.extname(self.path_original)
  end

  def path_original
    return APP_CONFIG[:photos_path] + self.path
  end

  def path_modified(size)
    return APP_CONFIG[:thumbs_path] + self.album.path + "/" + self.id.to_s + "_" + size + self.extension
  end

  private

  def set_title
    self.title = File.basename( self.path ).gsub( self.extension, "" ).titleize unless self.title
  end
  
  def ensure_file
    self.destroy if !File.exists?( APP_CONFIG[:photos_path] + self.path )
  end

  def exif_read
    photo = MiniExiftool.new(self.path_original)
    self.longitude = photo.GPSLongitude if self.longitude.nil?
    self.latitude = photo.GPSLatitude if self.latitude.nil?
    self.title = photo.DocumentName if self.title.nil?
    self.description = photo.ImageDescription if self.description.nil? || photo.ImageDescription != 'Exif_JPEG_PICTURE'
    self.tag_list = (self.tags.empty? ? "" : self.album.tag_list) + " " + (photo.Keywords.nil? ? "" : photo.Keywords.to_a.map { |tag| tag.gsub(" ", "_") }.join(" "))
  end
  
  def exif_write
    photo = MiniExiftool.new(self.path_original)
    photo.GPSLongitude = self.longitude
    photo.GPSLatitude = self.latitude
    photo.DocumentName = self.title
    photo.ImageDescription = self.description
    photo.Keywords = self.tags
    photo.save
  end
  
  def destroy_file
    #puts "DELETE THUMBS OF " + APP_CONFIG[:photos_path] + self.path
    File.delete( self.path_original ) if File.exists?( self.path_original )
    File.delete( self.path_modified("_collection") ) if File.exists?( self.path_modified("_collection") )
    File.delete( self.path_modified("_album") ) if File.exists?( self.path_modified("_album") )
    File.delete( self.path_modified("_single") ) if File.exists?( self.path_modified("_single") )
    File.delete( self.path_modified("_preview") ) if File.exists?( self.path_modified("_preview") )
  end
end
