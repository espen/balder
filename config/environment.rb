# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


Rails::Initializer.run do |config|

  config.gem "authlogic"  
  config.gem 'mime-types', :lib => 'mime/types'
  #config.gem "image_science"
  
  config.load_paths += %W( #{RAILS_ROOT}/app/middleware )

  config.time_zone = 'Copenhagen'

  config.i18n.default_locale = 'no-NB'

  config.action_controller.session = {
    :session_key => '_gallery_session',
    :secret      => '060feafeop90cuepaiam324eoimxeaioa2b4220c445486dace48f53fc0a0d4ec4e8de033e1db323628d66b6cx990loibjustintime99'
  }

  config.action_mailer.smtp_settings = {
    :address        => "smtp.gmail.com",
    :port           => 587,
    :domain         => "espen@inspired.no",
    :authentication => :plain,
    :user_name      => "espen@inspired.no",
    :password       => "tkg5megmeg"
  }
end