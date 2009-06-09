class DataTypesController < ApplicationController
  # Hack to provide a consistent department within the data controller
  before_filter :set_department_for_data   #department is STC


  def index
    @data_types = DataType.find_all_by_department_id(@department.id)
  end
  
  def show
    @data_type = DataType.find(params[:id])
  end
  
  def new
    @data_type = DataType.new
  end
  
  def create
    @data_type = DataType.new(params[:data_type])
    @data_type.department = @department
    if @data_type.save
      flash[:notice] = "Successfully created datatype."
      redirect_to @data_type
    else
      render :action => 'new'
    end
  end
  
  def edit
    @data_type = DataType.find(params[:id])
  end
  
  def update
    @data_type = DataType.find(params[:id])
    if @data_type.update_attributes(params[:data_type])
      flash[:notice] = "Successfully updated datatype."
      redirect_to @data_type
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_type = DataType.find(params[:id])
    @data_type.destroy
    flash[:notice] = "Successfully destroyed datatype."
    redirect_to data_types_url
  end
  
  private
  
  def set_department_for_data
    @department = Department.find_by_name("STC")
  end

end
