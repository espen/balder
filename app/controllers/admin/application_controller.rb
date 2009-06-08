class Admin::ApplicationController < ApplicationController
  
	before_filter :require_role_admin

end
