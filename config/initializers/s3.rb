CarrierWave.configure do |config|
      config.s3_access_key_id = APP_CONFIG[:s3_access_key_id]
      config.s3_secret_access_key = APP_CONFIG[:s3_secret_access_key]
      config.s3_bucket = APP_CONFIG[:s3_bucket]
    end