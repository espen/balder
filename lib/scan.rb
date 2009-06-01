module ScanFiles
#  protected
  require "find"
  #require 'RMagick'

  supported_files = ["jpeg", "jpg", "gif", "png"]

  def self.FullScan
    prevalbum = ""
    Find.find( APP_CONFIG[:photos_path] ) { |path|
      if File.file?(path) && [".jpeg", ".jpg", ".gif", ".png"].include?( File.extname(path) )
        relpath = File.dirname( path ).sub(APP_CONFIG[:photos_path], '')
        relfile = path.sub(APP_CONFIG[:photos_path], '')
        album = Album.find_by_path( relpath )
        if prevalbum != relpath
          puts relpath
          prevalbum = relpath
        end
        if album.nil?
          puts "New album : " + File.basename( relpath )
          album = Album.create( :path => relpath, :title => File.basename( File.dirname(path) ) )
        end
        photo = Photo.find_by_path( relfile )
        if photo.nil?
          puts "  New photo added " + relfile
          photo = Photo.create( :album => album, :title => File.basename(path).sub( File.extname(path), '' ) , :path => relfile )
        else
          puts "  Found photo " + relfile
        end
      end
    }
  end
  
  def self.CreateThumbnail(photo,image,thumbname,width,height)
    puts "Create thumb of " + photo.path
    thumb = image.first.resize_to_fill( width, height)
    thumb2 = image.first.change_geometry!("#{width}x#{ height }") { |cols, rows, img|
      if cols < width.to_i || rows < height.to_i
        puts "first if"
        img.resize!(cols, rows)
        bg = Magick::Image.new( width, height){self.background_color = "white"}
        bg.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)
      else
        puts "second if"
        img.resize!(cols, rows)
      end
    }
    puts "hello"
    puts "write... " + APP_CONFIG[:thumbs_path] + photo.album.path + "/" + photo.id.to_s + "_" + thumbname + File.extname( APP_CONFIG[:photos_path] + photo.path )
    thumb.write(APP_CONFIG[:thumbs_path] + photo.album.path + "/" + photo.id.to_s + "_" + thumbname + File.extname( APP_CONFIG[:photos_path] + photo.path ) )  { self.quality = 100 }
    #image.change_geometry!(MAINSITE_SIZE) { |cols, rows, img|
    #  img.resize!(cols, rows)
    #}
    #image.write(mainsite_file)
  end

  def self.FullScanOld
    self.ScanDirectory(APP_CONFIG[:photo_directory])
  end

  def self.ScanDirectory(dir)
    puts "now scanning: " + dir
    Dir.entries( dir ).select { |f| (f != "." && f != "..") }.each { |f|
        if ( File.directory?( dir + f))
          puts "found directory scan more.. " + dir + f + "/"
          self.ScanDirectory( dir + f )
        elsif ( supported_files.include?( File.extname(dir + f) ) )
          puts "insert file in database: " + f
        end
      }
  end
end