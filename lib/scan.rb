module ScanFiles
  require "find"
  require "fileutils"

  #require "scan";ScanFiles.Scan
  @photos_path = File.expand_path( './public/' + ENV['STORAGE_PATH'] + '/files' ) + '/'
  
  def self.Scan(debug = true)
    puts " IN DEBUG MODE " if debug
    self.ScanDirectory( @photos_path , debug )
  end
  
  
  def self.ScanDirectory(path, debug)
    path = File.expand_path( path )
    puts "analyze directory " + path
    Dir.entries( path ).each {|entry|
      pathentry = path + "/" + entry
      if File.directory?(pathentry) && !([".", ".."].include?( entry ))
        album = Album.find_or_initialize_by_path( pathentry.sub( @photos_path, '' ) )
        if album.new_record?
          puts "Save album " + pathentry.sub( @photos_path, '')
          album.save! unless debug
        end
        self.ScanDirectory(pathentry, debug)
      elsif File.file?(pathentry)
        self.ScanFile(pathentry, debug)
      else
        puts "ignoring " + pathentry 
      end
    }
  end
  
  def self.ScanFile(path, debug)
    return unless [".jpeg", ".jpg", ".gif", ".png"].include?( File.extname(path).downcase )
    puts "analyze file " + path
    photo = Photo.find_or_initialize_by_path( path )
    puts "new record " + photo.new_record?.to_s
    if photo.new_record?
      puts "Save file " + path.sub(@photos_path, '')
      photo.file = File.open( path ) unless debug
      photo.album = Album.find_by_path( File.dirname( path ).sub(@photos_path, '') )
      photo.save! unless debug
      photo.file.recreate_versions! unless debug
    end
  end
  
  def self.RecreateThumbnails
    Photo.find(:all).each {|photo|
        photo.file.recreate_versions!
      }
  end

end