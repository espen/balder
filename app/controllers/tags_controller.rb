class TagsController < ApplicationController
  before_filter :check_public_access

  def index
    if params[:album_id]
      @tags = Album.find( params[:album_id] ).photo_tags
    else
      @tags = Tag.order('title')
    end
    respond_to do |format|
      format.html
      format.json  { render :json => @tags }
      format.xml  { render :xml => @tags }
    end
  end
end
