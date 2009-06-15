class DataFieldsController < ApplicationController
  # Hack to provide a consistent department within the data controller
  before_filter :set_department_for_data   #department is STC
  
  def index
		if params[:data_type_id]
      @data_fields = DataField.find_all_by_data_type_id(params[:data_type_id])
    else
      flash[:error] = "You must specify a data type before viewing associated
                        objects."
      redirect_to data_types_path
    end
  end
  
  def show
    @data_field = DataField.find(params[:id])
  end
  
  def new
    @data_field = DataField.new
  end
  
  def create
    @data_field = DataField.new(params[:data_field])
    @data_field.data_type_id = params[:data_type_id]
    if @data_field.save
      flash[:notice] = "Successfully created data field."
      redirect_to data_type_data_fields_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @data_field = DataField.find(params[:id])
  end
  
  def update
    @data_field = DataField.find(params[:id])
    if @data_field.update_attributes(params[:data_field])
      flash[:notice] = "Successfully updated data field."
      redirect_to @data_field
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_field = DataField.find(params[:id])
    @data_field.destroy
    flash[:notice] = "Successfully destroyed data field."
    redirect_to data_fields_url
  end
  
  private
  
  def set_department_for_data
    @department = Department.find_by_name("STC")
  end
  
end
