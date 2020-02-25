source 'https://rubygems.org'

ruby '2.5.7'

gem 'rails', '~> 3.2'
gem 'json'

gem 'authlogic'
gem 'omniauth'
gem 'omniauth-facebook'

gem 'mime-types', :require => 'mime/types'
gem 'carrierwave', '~> 0.6.1'

# -- Database
# SQLite:
group :development do
  gem 'sqlite3', '<1.4'
  gem 'sqlite3-ruby'
end
group :production do
  gem 'unicorn'
  gem 'rails_12factor'
  # MySQL:
  #gem 'mysql2'
  # PostgreSQL (default on heroku):
  gem 'pg', '<1'
end
gem 'test-unit'

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
