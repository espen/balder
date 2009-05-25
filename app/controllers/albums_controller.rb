class AlbumsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :delete, :destroy]
  
  def index
    @albums = Album.find(:all)
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
    if @album.save
      Dir.mkdir( APP_CONFIG[:photos_path] + @album.title )
      Dir.mkdir( APP_CONFIG[:thumbs_path] + @album.title )
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
      flash[:notice] = "Account updated!"
      redirect_to @album
    else
      render :action => :edit
    end
  end
  
  def destory
    @album = Album.find( params[:id])
    if @album.destory
      redirect_to album_path
    else
      redirect_to @album
    end
  end
  
end
