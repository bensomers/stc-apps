class DataObjectsController < ApplicationController
  def index
    if params[:data_type_id]
      @data_objects = DataObject.find_all_by_data_type_id(params[:data_type_id])
    else
      flash[:error] = "You must specify a data type before viewing associated
                        objects."
      redirect_to data_types_path
    end
  end
  
  def show
    @data_object = DataObject.find(params[:id])
  end
  
  def new
    @data_type = DataType.find(params[:data_type_id]) || DataType.new
    @data_object = DataObject.new ({:data_type_id => params[:data_type_id]})
  end
  
  def create
    @data_object = DataObject.new(params[:data_object])
    @data_object.data_type_id = params[:data_type_id]
    if @data_object.save
      flash[:notice] = "Successfully created data object."
      redirect_to data_type_data_objects_path
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
      flash[:notice] = "Successfully updated data object."
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
