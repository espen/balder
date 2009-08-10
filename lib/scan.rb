module ScanFiles
  require "find"
  require "fileutils"

  #require "scan";ScanFiles.Scan
  
  def self.Scan(debug = true)
    puts " IN DEBUG MODE " if debug
    self.ScanDirectory( APP_CONFIG[:photos_path], debug )
  end
  
  
  def self.ScanDirectory(path, debug)
    path = File.expand_path( path )
    puts "analyze directory " + path
    Dir.entries( path ).each {|entry|
      pathentry = path + "/" + entry
      if File.directory?(pathentry) && !([".", ".."].include?( entry ))
        album = Album.find_by_path( pathentry ) || Album.new()
        unless entry == entry.parameterize
          puts pathentry + " will now be moved to " + path + "/" + entry.parameterize
          #FileUtils.mv( pathentry, entry.parameterize)
          File.rename( pathentry, path + "/" + entry.parameterize ) unless debug
          pathentry = path + "/" + entry.parameterize
        end
        album.path = pathentry
        album.save! unless debug
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
    pathentry = path
    photo = Photo.find_by_path( path ) || Photo.new()
    unless File.basename( path, File.extname(path) ) == File.basename(path, File.extname(path)).parameterize
      pathentry = File.dirname(path) + "/" + File.basename( path, File.extname(path) ).parameterize  + File.extname(path).downcase
      puts path + " will now be moved to " + pathentry
      #FileUtils.mv( path, File.basename( path, File.extname(path) ).parameterize + File.extname(path).downcase )
      #File.move( path, File.dirname(path) + "/" + File.basename( path, File.extname(path) ).parameterize + File.extname(path) )
      File.rename( path, pathentry ) unless debug
    end
    photo.path = pathentry
    photo.save! unless debug
  end

  def self.FullScan(debug = false)
    if debug
      puts "DEBUG"
    end
    puts "Scanning " + APP_CONFIG[:photos_path]
    prevalbum = ""
    dirs = Array.new
    Find.find( APP_CONFIG[:photos_path] ) { |path|
      dirs.push( path )
    }
    dirs.sort.each{|path|
      if File.file?(path) && [".jpeg", ".jpg", ".gif", ".png"].include?( File.extname(path).downcase )
        relpath = File.dirname( path ).sub(APP_CONFIG[:photos_path], '')
        relfile = path.sub(APP_CONFIG[:photos_path], '')
        puts relpath
        album = Album.find_by_path( relpath )

        relpathparam = ""
        relpath.split("/").each{|d|
          relpathparam += d.parameterize + "/"
        }
        relpathparam = relpathparam.slice(0..relpathparam.length-2)
        if relpath != relpathparam
          puts APP_CONFIG[:photos_path] + relpath + " will now be moved to " + APP_CONFIG[:photos_path] + relpathparam
          FileUtils.mv(APP_CONFIG[:photos_path] + relpath, APP_CONFIG[:photos_path] + relpathparam) unless debug
          FileUtils.mv(APP_CONFIG[:thumbs_path] + relpath, APP_CONFIG[:thumbs_path] + relpathparam) unless debug
          puts "reload!"
          self.FullScan unless debug
          return unless debug
        end

        if prevalbum != relpath
          puts relpath
          prevalbum = relpath
        end
        if album.nil?
          puts "New album : " + File.basename( relpath )
          album = Album.new()
          album.path = relpath
          unless debug || album.save
            raise "unable to save album"
          end
          puts "reload!"
          self.FullScan unless debug
          return unless debug
        end
        photo = Photo.find_by_path( relfile )

        photorelpathparam = ""
        relfile.split("/").each{|d|
          photorelpathparam += d.parameterize + "/"
        }
        photorelpathparam = photorelpathparam.slice(0..photorelpathparam.length-2)
        puts "check if photo " + relfile + " = " + photorelpathparam
        if relfile != photorelpathparam
          puts APP_CONFIG[:photos_path] + relfile + " will now be moved to " + APP_CONFIG[:photos_path] + photorelpathparam
          unless photo.nil?
            photo.path = photorelpathparam
            photo.save! unless debug
          end
          FileUtils.mv(APP_CONFIG[:photos_path] + photo.path, APP_CONFIG[:photos_path] + photorelpathparam) unless debug
          FileUtils.mv(APP_CONFIG[:thumbs_path] + photo.path, APP_CONFIG[:thumbs_path] + photorelpathparam) unless debug
        end

        if photo.nil?
          puts "  New photo added " + photorelpathparam
          photo = Photo.new(  )
          photo.album = album
          photo.path = photorelpathparam
          unless debug || photo.save
            raise "unable to save photo"
          end
        else
          puts "  Found photo " + relfile
        end
      end
    }
    return
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