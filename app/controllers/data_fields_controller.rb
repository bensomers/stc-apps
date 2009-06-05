class DataFieldsController < ApplicationController
  def index
    @data_fields = DataField.all
  end
  
  def show
    @data_field = DataField.find(params[:id])
  end
  
  def new
    @data_field = DataField.new
  end
  
  def create
    @data_field = DataField.new(params[:data_field])
    if @data_field.save
      flash[:notice] = "Successfully created datafield."
      redirect_to @data_field
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
      flash[:notice] = "Successfully updated datafield."
      redirect_to @data_field
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_field = DataField.find(params[:id])
    @data_field.destroy
    flash[:notice] = "Successfully destroyed datafield."
    redirect_to data_fields_url
  end
end