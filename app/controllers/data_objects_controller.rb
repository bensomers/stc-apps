class DataObjectsController < ApplicationController
  #User admin methods will need to be rewritten in move to other codebase
  def index
    if params[:data_type_id]
      @data_objects = DataObject.find_all_by_data_type_id(params[:data_type_id])
    elsif is_admin_of?(@department)
      @data_objects = DataObject.by_department(@department)
    elsif location_group_admin
      @data_objects = DataObject.by_location_group(user.location_group_admin)
    end
  end
  
  def show
    @data_object = DataObject.find(params[:id])
  end
  
  def new
    @data_object = DataObject.new
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
    flash[:notice] = "Successfully destroyed data object."
    redirect_to data_objects_url
  end
  
  private
  
  def is_admin_of?(dept)
    return true
  end
  
  def location_group_admin
    return LocationGroup.first
  end
  
end
