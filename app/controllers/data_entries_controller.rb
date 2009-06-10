class DataEntriesController < ApplicationController
  def index
    if params[:data_object_id]
      @data_entries = DataEntry.find_all_by_data_object_id(params[:data_object_id])
    else
      flash[:error] = "You must specify a data object before viewing associated
                        entries."
      redirect_to data_objects_path
    end
  end
  
  def show
    @data_entry = DataEntry.find(params[:id])
  end
  
  def new
    @data_entry = DataEntry.new
  end
  
  def create
    @data_entry = DataEntry.new(params[:data_entry])
    @data_entry.data_object_id = params[:data_object_id]
    if @data_entry.save
      flash[:notice] = "Successfully created data entry."
      redirect_to @data_entry
    else
      render :action => 'new'
    end
  end
  
  def edit
    @data_entry = DataEntry.find(params[:id])
  end
  
  def update
    @data_entry = DataEntry.find(params[:id])
    if @data_entry.update_attributes(params[:data_entry])
      flash[:notice] = "Successfully updated dataentry."
      redirect_to @data_entry
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_entry = DataEntry.find(params[:id])
    @data_entry.destroy
    flash[:notice] = "Successfully destroyed dataentry."
    redirect_to data_entries_url
  end
end
