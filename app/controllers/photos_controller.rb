class PhotosController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]

  def index
    @photos = Tag.find_by_title( params[:tag_id] ).photos
    respond_to do |format|
      format.html
      format.json  { render :json => @photos }
      format.xml  { render :xml => @photos }
    end
  end
  
  def show
    @photo = Photo.find( params[:id])
    respond_to do |format|
      format.html
      format.json  { render :json => @photo }
      format.xml  { render :xml => @photo }
    end
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(params[:photo])
    if @photo.save
      # upload
      flash[:notice] = "Photo created!"
      redirect_to @photo
    else
      render :action => :new
    end
  end
  
  def edit
    @photo = Photo.find( params[:id])
  end

  def update
    @photo = Photo.find( params[:id])
    if @photo.update_attributes(params[:photo])
      flash[:notice] = "Account updated!"
      redirect_to @photo
    else
      render :action => :edit
    end
  end
  
  def destory
    @photo = Photo.find( params[:id])
    if @photo.destory
      redirect_to photo_path
    else
      redirect_to @photo
    end
  end
end
