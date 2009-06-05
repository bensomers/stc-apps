class DataTypesController < ApplicationController
  def index
    @data_types = DataType.all
  end
  
  def show
    @data_type = DataType.find(params[:id])
  end
  
  def new
    @data_type = DataType.new
  end
  
  def create
    @data_type = DataType.new(params[:data_type])
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
end
