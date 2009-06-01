module AlbumsHelper
  def new_upload_path_with_session_information
      session_key = ActionController::Base.session_options[:key]
      photos_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
  end

  def get_session_key
    ActionController::Base.session_options[:key]
  end
end
