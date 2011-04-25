# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  helper_method :current_user, :current_user_session
  
  before_filter :setup

  
  private
  
    def setup
      redirect_to new_account_path if User.all.length == 0
    end
  
    def check_public_access
      require_user if ENV['PRIVATE'] == 'true'
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_role(roles = [])
      unless current_user && current_user.in_role?(*roles)
        store_location
        flash[:notice] = "You must have permission to access this page"
        redirect_to account_path
        return false
      end
      return true
    end

    def require_role_admin
      return false if !require_user
      return require_role("admin")
    end
    
    def require_permission(permissions = [])
      return false if !require_user
      unless current_user && current_user.has_permission?(*permissions)
        store_location
        flash[:notice] = "You must have permission to access this page"
        redirect_to account_path
        return false
      end
      return true
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to login_path
        return false
      end
      return true
    end
 
    def require_no_user
      if current_user
        store_location
        flash[:notice] = "Already logged in. Please logout"
        redirect_to account_path
        return false
      end
      return true
    end
    
    def store_location
      session[:return_to] = request.fullpath
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end  
end
