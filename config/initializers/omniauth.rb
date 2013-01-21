Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :facebook, '514233915287967', 'c3e63b8953d65c332ebb3a84dc2dc8c0'
end