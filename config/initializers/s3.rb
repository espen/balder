CarrierWave.configure do |config|
  config.s3_access_key_id = ENV['S3_KEY']
  config.s3_secret_access_key = ENV['S3_SECRET']
  config.s3_bucket = ENV['S3_BUCKET']
  #config.fog_credentials = {
  #    :provider               => 'AWS',
  #    :aws_access_key_id      => ENV['S3_KEY'],
  #    :aws_secret_access_key  => ENV['S3_SECRET'],
  #    :region                 => 'us-east-1'
  #}
  #config.fog_directory  = ENV['S3_BUCKET']
end