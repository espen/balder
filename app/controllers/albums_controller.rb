class AlbumsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :delete, :destroy, :upload]
  
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
      flash[:notice] = "Account updated!"
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
  
  def upload
    @user = current_user_session
    @album = Album.find( params[:id])
  end
  
end
