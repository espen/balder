source 'http://rubygems.org'

group :heroku do
  gem 'thin'
end

gem 'rails', '3.2.12'

gem 'authlogic'

gem 'mime-types', :require => 'mime/types'
gem 'carrierwave', '0.6.1'

# -- Heroku
#gem 'heroku'
#gem 'pg'

# -- Database
# SQLite:
group :development do
  gem 'sqlite3-ruby'
end
# MySQL:
#gem 'mysql2'
# PostgreSQL:
gem 'pg'

# -- Cloud storage
# AWS S3 support. Can be disabled if using local file system instead of cloud storage.
gem 'fog'

# -- Photo resizing
# MiniMagick
gem "mini_magick"

# ImageMagick:
#gem "rmagick", :require => 'RMagick'

# FreeImage:
#gem "RubyInline"
#gem "image_science", :git => 'git://github.com/perezd/image_science.git'

# -- EXIF
# Mini exif tool. Can be disabled. Remove exif_read and exif_write filters in photo model
gem "mini_exiftool_vendored"