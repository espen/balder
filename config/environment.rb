# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


Rails::Initializer.run do |config|

  config.gem "authlogic"
  config.gem 'mime-types', :lib => 'mime/types'
  config.gem "image_science"
  #config.gem "mini_exiftool"
  
  config.load_paths += %W( #{RAILS_ROOT}/app/middleware )

  config.time_zone = 'Copenhagen'

  config.i18n.default_locale = 'no-NB'

end