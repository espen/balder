After do
require "find"
Find.find( APP_CONFIG[:photos_path] ) { |path|
  Dir.delete( path ) if path != APP_CONFIG[:photos_path] && File.directory?(path)
}
Find.find( APP_CONFIG[:thumbs_path] ) { |path|
  Dir.delete( path ) if path != APP_CONFIG[:thumbs_path] && File.directory?(path)
}
end