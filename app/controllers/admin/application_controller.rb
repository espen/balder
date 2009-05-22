class Admin::ApplicationController < ApplicationController
  
  
  protected
  
	before_filter :login_required
  
end
