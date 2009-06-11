class AlbumsController < ApplicationController

  before_filter :require_role_admin, :only => [:untouched, :new, :create, :edit, :update, :destroy]
  
  def index
    if params[:tag_id]
      @albums = Album.find(:all, :conditions => [ "Id IN ( SELECT DISTINCT Photos.ALbum_id FROM Photos WHERE Photos.Id IN ( SELECT Photo_Id FROM Photo_Tags WHERE Photo_Tags.Tag_Id = :q) )", { :q => Tag.find_by_title( params[:tag_id] ).id } ])
    elsif params[:q]
      @albums = Album.find(:all, :conditions => [ "Id IN ( SELECT DISTINCT Photos.Album_Id FROM Photos WHERE Photos.description LIKE :q OR Photos.title LIKE :q OR Photos.Id IN ( SELECT Photo_Id FROM Photo_Tags LEFT OUTER JOIN Tags ON Photo_Tags.Tag_Id = Tags.Id WHERE Tags.Title LIKE :q) )", { :q => '%' + params[:q] + '%' } ])
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
    @album = Album.find_by_title( params[:id])
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
