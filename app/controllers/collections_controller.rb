class CollectionsController < ApplicationController
  
  before_filter :require_role_admin, :only => [:new, :create, :edit, :update, :destroy]  
  def index
    @collections = Collection.find(:all)
    respond_to do |format|
      format.html
      format.json  { render :json => @collections }
      format.xml  { render :xml => @collections }
    end
  end
  
  def show
    @collection = Collection.find_by_title( params[:id] )
    respond_to do |format|
      format.html
      format.json  { render :json => @collection }
      format.xml  { render :xml => @collection }
      format.pdf { render :pdf => @collection.title }
    end
  end
    
  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(params[:collection])
    if @collection.save
      flash[:notice] = "Collection created!"
      redirect_to @collection
    else
      render :action => :new
    end
  end
  
  def edit
    @collection = Collection.find( params[:id])
  end

  def update
    @collection = Collection.find( params[:id])
    if @collection.update_attributes(params[:collection])
      flash[:notice] = "Collection updated!"
      redirect_to @collection
    else
      render :action => :edit
    end
  end
  
  def destroy
    @collection = Collection.find( params[:id])
    if @collection.destroy
      redirect_to collections_path
    else
      redirect_to @collection
    end
  end
  
end
