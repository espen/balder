class AlbumsController < ApplicationController

  before_filter :require_role_admin, :only => [:untouched, :new, :create, :edit, :update, :destroy]
  
  def index
    if params[:tag_id]
      @albums = Album.find(:all, :conditions => [ "id IN ( SELECT DISTINCT photos.album_id FROM photos WHERE photos.id IN ( SELECT photo_id FROM photo_tags WHERE photo_tags.tag_id = :q) )", { :q => Tag.find( params[:tag_id] ).id } ])
    elsif params[:q]
      @albums = Album.find(:all, :conditions => [ "id IN ( SELECT DISTINCT photos.album_id FROM photos WHERE photos.description LIKE :q OR photos.title LIKE :q OR photos.id IN ( SELECT photo_id FROM photo_tags LEFT OUTER JOIN tags ON photo_tags.tag_id = tags.id WHERE tags.title LIKE :q) )", { :q => '%' + params[:q] + '%' } ])
    else
      @albums = Album.find(:all)
    end
    respond_to do |format|
      format.html
      format.json  { render :json => @albums }
      format.xml  { render :xml => @albums }
    end
  end

  def untouched
    @albums = Album.untouched()
    respond_to do |format|
      format.html
      format.json  { render :json => @albums }
      format.xml  { render :xml => @albums }
    end
  end
  
  def show
    @album = Album.find( params[:id])
    respond_to do |format|
      format.html
      format.json  { render :json => @album }
      format.xml  { render :xml => @album }
      format.pdf { render :pdf => @album.title }
    end
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new(params[:album])
    @album.path = @album.title
    if @album.save
      if params[:collection_id]
        @album.collections << Collection.find( params[:collection_id] )
      end
      flash[:notice] = "Album created!"
      redirect_to @album
    else
      render :action => :new
    end
  end

  def edit
    @album = Album.find( params[:id])
  end

  def update
    @album = Album.find( params[:id])
    if @album.update_attributes(params[:album])
      flash[:notice] = "Album updated!"
      redirect_to @album
    else
      render :action => :edit
    end
  end
  
  def destroy
    @album = Album.find( params[:id])
    if @album.destroy
      redirect_to albums_path
    else
      redirect_to @album
    end
  end
  
end
