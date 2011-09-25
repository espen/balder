class PhotosController < ApplicationController
  before_filter :check_public_access
  before_filter :require_role_admin, :only => [:untouched, :upload, :new, :create, :edit, :update, :destroy, :scan]

  def index
    if params[:tag_id] && params[:album_id]
      @tag = Tag.find_by_title!( params[:tag_id] )
      @photos = @tag.photos.find(:all, :conditions => ['photos.album_id = :album', {:album => Album.find(params[:album_id] ) } ], :order => "photos.id ASC")
    elsif params[:tag_id]
      @tag = Tag.find_by_title!( params[:tag_id] )
      @photos = @tag.photos.find(:all, :order => "photos.id ASC")
    elsif params[:album_id]
      @album = Album.find( params[:album_id])
      @photos = @album.photos.find(:all, :order => "photos.id ASC")
    elsif params[:q]
      #search = params[:q]
      #search = search.split("AND").map{|q|q.strip}
      #@photos = Photo.find(:all, :select => 'DISTINCT photos.id, photos.album_id, photos.title, photos.path', :limit => 20, :conditions => {  :tags => {:title => search}}, :joins => 'LEFT OUTER JOIN photo_tags ON photos.id = photo_tags.photo_id LEFT OUTER JOIN tags ON photo_tags.tag_id = tags.id', :include => [:album], :order => "photos.title ASC" )
      params[:q].split(" AND ").each {|q|
        qphotos = Photo.find(:all, :limit => 20, :conditions => [ "photos.description LIKE :q OR photos.title LIKE :q OR photos.id IN ( SELECT photo_id FROM photo_tags LEFT OUTER JOIN tags ON photo_tags.tag_id = tags.id WHERE tags.title = :t) ", { :q => '%' + q + '%', :t => q } ], :include => :album, :order => "photos.id ASC" )
        if @photos
          @photos = @photos & qphotos
        else
          @photos = qphotos
        end
      }
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
  
  def scan
  	require "scan"
  	ScanFiles.Scan(false)
  	redirect_to(root_path)
  end

  def new
    @photo = Photo.new
  end

  def upload
    @album = Album.find( params[:album_id])
  end

  def create
    @photo = Photo.new(params[:photo])
    @photo.file = params[:file]
    respond_to do |format|
        if @photo.save
          format.html { render :text => "FILEID:" + @photo.file.album.url }
          format.xml  { render :nothing => true }
        else
          format.html { render :text => "ERRORS:" + @photo.errors.full_messages.join(" "), :status => 500 }
          format.xml  { render :xml => @photo.errors, :status => 500 }
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
      if params[:collection_id]
        redirect_to collection_album_photo_path( params[:collection_id], params[:album_id], @photo )
      elsif params[:album_id]
        redirect_to album_photo_path( params[:album_id], @photo )
      else
        redirect_to @photo
      end
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
      if params[:collection_id]
        redirect_to collection_album_path( params[:collection_id], @album )
      else
        redirect_to @album
      end
    else
      redirect_to @photo
    end
  end
end
