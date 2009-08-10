module ScanFiles
  require "find"
  require "fileutils"

  supported_files = ["jpeg", "jpg", "gif", "png"]

  def self.FullScan
    puts "Scanning " + APP_CONFIG[:photos_path]
    prevalbum = ""
    dirs = Array.new
    Find.find( APP_CONFIG[:photos_path] ) { |path|
      dirs.push( path )
    }
    dirs.sort.each{|path|
      if File.file?(path) && [".jpeg", ".jpg", ".gif", ".png"].include?( File.extname(path) )
        relpath = File.dirname( path ).sub(APP_CONFIG[:photos_path], '')
        relfile = path.sub(APP_CONFIG[:photos_path], '')
        puts relpath
        relpathdirs = relpath.split("/")
        relpathparam = ""
        relpathdirs.each{|d|
          relpathparam += d.parameterize + "/"
        }
        relpathparam = relpathparam.slice(0..relpathparam.length-2)
        album = Album.find_by_path( relpath )
        if relpath != relpathparam
          puts APP_CONFIG[:photos_path] + relpath + " will now be moved to " + APP_CONFIG[:photos_path] + relpathparam
          FileUtils.mv APP_CONFIG[:photos_path] + relpath, APP_CONFIG[:photos_path] + relpathparam
          puts "reload!"
          unless album.nil?
            album.path = relpathparam
            album.save!
          end
          self.FullScan
          return
        end

        if prevalbum != relpath
          puts relpath
          prevalbum = relpath
        end
        if album.nil?
          puts "New album : " + File.basename( relpath )
          album = Album.new()
          album.path = relpath
          unless album.save
            raise "unable to save album"
          end
        end
        photo = Photo.find_by_path( relfile )
        if photo.nil?
          puts "  New photo added " + relfile
          photo = Photo.new(  )
          photo.album = album
          photo.path = relfile
          unless photo.save
            raise "unable to save photo"
          end
        else
          puts "  Found photo " + relfile
        end
      end
    }
  end
  
  def self.RecreateThumbnails
    Photo.find(:all).each {|photo|
        photo.create_thumbnails()
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
    puts "write... " + APP_CONFIG[:thumbs_path] + photo.album.path + "/" + photo.id.to_s + "_" + thumbname + File.extname( APP_CONFIG[:photos_path] + photo.path )
    thumb.write(APP_CONFIG[:thumbs_path] + photo.album.path + "/" + photo.id.to_s + "_" + thumbname + File.extname( APP_CONFIG[:photos_path] + photo.path ) )  { self.quality = 100 }
    #image.change_geometry!(MAINSITE_SIZE) { |cols, rows, img|
    #  img.resize!(cols, rows)
    #}
    #image.write(mainsite_file)
  end

end