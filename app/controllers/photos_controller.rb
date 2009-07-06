class PhotosController < ApplicationController

  before_filter :require_role_admin, :only => [:untouched, :upload, :new, :create, :edit, :update, :destroy]

  def index
    if params[:tag_id] && params[:album_id]
      @photos = Tag.find_by_title( params[:tag_id] ).photos.find(:all, :conditions => ['photos.album_id = :album', {:album => Album.find(params[:album_id] ) } ], :order => "photos.id ASC")
    elsif params[:tag_id]
      @photos = Tag.find_by_title( params[:tag_id] ).photos.find(:all, :order => "photos.id ASC")
    elsif params[:album_id]
      @photos = Album.find( params[:album_id]).photos.find(:all, :order => "photos.id ASC")
    elsif params[:q]
      @photos = Photo.find(:all, :limit => 20, :conditions => [ "photos.description LIKE :q OR photos.title LIKE :q OR photos.id IN ( SELECT photo_id FROM photo_tags LEFT OUTER JOIN tags ON photo_tags.tag_id = tags.id WHERE tags.title LIKE :q) ", { :q => '%' + params[:q] + '%' } ], :include => :album, :order => "photos.id ASC" )
    else
      @photos = Photo.find(:all, :order => "photos.id ASC")
    end
    respond_to do |format|
      format.html
      format.json  { render :json => @photos }
      format.xml  { render :xml => @photos }
    end
  end
  
  def untouched
    if params[:album_id]
      @album = Album.find( params[:album_id])
      @photos = @album.photos.untouched
    else
      @photos = Photo.untouched()
    end
    respond_to do |format|
      format.html
      format.json  { render :json => @photos }
      format.xml  { render :xml => @photos }
    end
  end
  
  def show
    @photo = Photo.find( params[:id] )
    previous_rs = Photo.previous( @photo.id, @photo.album )
    @previous = previous_rs.first unless previous_rs.empty?
    next_rs = Photo.next( @photo.id, @photo.album )
    @next = next_rs.first unless next_rs.empty?
    respond_to do |format|
      format.html
      format.json  { render :json => @photo }
      format.xml  { render :xml => @photo }
    end
  end

  def new
    @photo = Photo.new
  end

  def upload
    @album = Album.find( params[:album_id])
  end

  def create
    respond_to do |format|
      @photo = Photo.new(params[:photo])
      if params[:Filedata]
        @photo.swf_uploaded_data = params[:Filedata]
        if @photo.save
          format.html { render :text => "FILEID:" + @photo.path_modified_public("album") }
          format.xml  { render :nothing => true }
        else
          format.html { render :text => "ERRORS:" + @photo.errors.full_messages.join(" "), :status => 500 }
          format.xml  { render :xml => @photo.errors, :status => 500 }
        end
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
    @tags = Tag.find(:all).map { |tag| tag.title }.join('\',\'')
  end
  
  def edit_multiple
    if params[:album_id]
      @album = Album.find( params[:album_id] )
      @photos = @album.photos
    else
      @photos = Photo.find( params[:photo_ids] )
    end
  end

  def update
    @photo = Photo.find( params[:id])
    if @photo.update_attributes(params[:photo])
      flash[:notice] = "Photo updated!"
      redirect_to @photo
    else
      render :action => :edit
    end
  end

  def update_multiple
    @photos = params[:photos][:photo]
    @photos.each do |photo_item|
      photo = Photo.find( photo_item[0] )
      if photo_item[1][:_delete] == "1"
        photo.destroy
      else
        photo.title = photo_item[1][:title]
        photo.tag_list = photo_item[1][:tags]
        photo.save
      end
    end
    flash[:notice] = "Updated photos!"
    redirect_to photos_path
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
