class TagsController < ApplicationController

  def index
    @tags = Tag.find( :all)
    respond_to do |format|
      format.html
      format.json  { render :json => @tags }
      format.xml  { render :xml => @tags }
    end
  end
end
