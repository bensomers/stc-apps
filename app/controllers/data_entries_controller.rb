class DataEntriesController < ApplicationController
  def index
    @data_entries = DataEntry.all
  end
  
  def show
    @data_entry = DataEntry.find(params[:id])
  end
  
  def new
    @data_entry = DataEntry.new
  end
  
  def create
    @data_entry = DataEntry.new(params[:data_entry])
    if @data_entry.save
      flash[:notice] = "Successfully created dataentry."
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
