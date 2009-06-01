class PhotosController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]

  def index
    if params[:tag_id]
      @photos = Tag.find_by_title( params[:tag_id] ).photos
    elsif params[:q]
      @photos = Photo.find(:all, :limit => 20, :conditions => [ "Photos.description LIKE :q OR Photos.title LIKE :q OR Photos.Id IN ( SELECT Photo_Id FROM Photo_Tags LEFT OUTER JOIN Tags ON Photo_Tags.Tag_Id = Tags.Id WHERE Tags.Title LIKE :q) ", { :q => '%' + params[:q] + '%' } ], :include => :album )
    else
      @photos = Photo.find(:all, :limit => 20)
    end
    respond_to do |format|
      format.html
      format.json  { render :json => @photos }
      format.xml  { render :xml => @photos }
    end
  end
  
  def untouched
    @photos = Photo.untouched()
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
    

    respond_to do |format|
      @photo = Photo.new(params[:photo])
      if params[:Filedata]
        @photo.swf_uploaded_data = params[:Filedata]
        @photo.save!

        format.html { render :text => "FILEID:" + @photo.public_path_modified("album") }
        format.xml  { render :nothing => true }
      else
        if @photo.save
          flash[:notice] = 'Created'
          format.html { redirect_to(@photo) }
          format.xml  { render :xml => @photo }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @photo.errors }
        end
      end
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
  
  def destroy
    @photo = Photo.find( params[:id])
    @album = @photo.album
    if @photo.destroy
      redirect_to @album
    else
      redirect_to @photo
    end
  end
end
