# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Load heroku vars from local file
balder_env = File.join(RAILS_ROOT, 'config', 'balder.rb')
load(balder_env) if File.exists?(balder_env)


Rails::Initializer.run do |config|

  config.gem "authlogic"
  config.gem 'mime-types', :lib => 'mime/types'
  config.gem "carrierwave"
  config.gem "mysql2"
  #config.gem "mini_exiftool"
  #config.gem "aws-s3", :lib => "aws/s3"
  
  config.load_paths += %W( #{RAILS_ROOT}/app/middleware )
      
end