# Load the rails application
require File.expand_path('../application', __FILE__)

# Load app vars from local file
balder_env = File.join(Rails.root, 'config', 'balder.rb')
load(balder_env) if File.exists?(balder_env)

# Initialize the rails application
Balder::Application.initialize!