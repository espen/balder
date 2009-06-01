class Admin::ApplicationController < ApplicationController
  
	before_filter :require_user, :require_role_admin
  
  protected 
  
  def require_role_admin
    redirect_to(login_path) unless @current_user
  end

end
