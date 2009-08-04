#APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")[RAILS_ENV].symbolize_keys
APP_CONFIG = YAML.load(ERB.new(File.read("#{RAILS_ROOT}/config/settings.yml")).result)[RAILS_ENV].symbolize_keys
