Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  (provider :facebook, ENV['FACEBOOK_ID'], ENV['FACEBOOK_SECRET']) unless ENV['FACEBOOK_ID'].nil?
end