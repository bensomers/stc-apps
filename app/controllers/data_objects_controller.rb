class DataObjectsController < ApplicationController
  def index
    @data_objects = DataObject.all
  end
  
  def show
    @data_object = DataObject.find(params[:id])
  end
  
  def new
    @data_object = DataObject.new
  end
  
  def create
    @data_object = DataObject.new(params[:data_object])
    if @data_object.save
      flash[:notice] = "Successfully created dataobject."
      redirect_to @data_object
    else
      render :action => 'new'
    end
  end
  
  def edit
    @data_object = DataObject.find(params[:id])
  end
  
  def update
    @data_object = DataObject.find(params[:id])
    if @data_object.update_attributes(params[:data_object])
      flash[:notice] = "Successfully updated dataobject."
      redirect_to @data_object
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_object = DataObject.find(params[:id])
    @data_object.destroy
    flash[:notice] = "Successfully destroyed dataobject."
    redirect_to data_objects_url
  end
end
