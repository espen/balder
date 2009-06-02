# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gallery_session',
  :secret      => '06xfeafeop90cuepaiam324eoimxeaioa2b4220c445486dace48f53fc1a0d4ec4e8de033e1db323628d66b6cx990loibjustintime99'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

ActionController::Dispatcher.middleware.insert_before(ActionController::Session::CookieStore, FlashSessionCookieMiddleware, ActionController::Base.session_options[:key])
#ActionController::Dispatcher.middleware.use FlashSessionCookieMiddleware, ActionController::Base.session_options[:key]