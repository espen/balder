class Admin::ApplicationController < ApplicationController
  
	before_filter :require_user, :require_role_admin

end
