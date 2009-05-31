class DataController < ShiftAdminController
#  before_filter :fetch_data #this is already called in shift_admin controller
  
  layout "shift"

  def controller_name
    ShiftAdminController.controller_name
  end
  
  def index
    ##if all of the methods include "prepare_data", we could just use a before_filter
    ##if most use "prepare_data", but not all, we could use "before_filter except" - Steven
  end

  def view_data_type
    @auth_data_objects = @locations.collect(&:data_objects).flatten
    @data_type = DataType.find(params[:id])
  rescue Exception => e
    redirect_with_flash e.message and return
  else
#    if request.xhr?
#      next_field = DataType.string_fields[DataType.string_fields.index(params[:field]) + 1]     
#      render :update do |page|
##        page.insert_html :after, "data_type_" + params[:field], 
##                         :partial => "data_type_form", :object => @data_type
##        page.replace_html (params[:field], :partial => "data_type_field",
##                          :object => params[:field]) 
#          page.show next_field
#      end
#    end
    if request.post? and department_admin?
      @data_type.update_attributes(params[:data_type])
    end
  end
  
  def view_data_object
    @data_object = DataObject.find(params[:id])
    if params[:view_all]
      @object_entries = @data_object.data_entries
    else
      @object_entries = @data_object.data_entries.find(:all, :conditions => ["updated_at > ?", 1.week.ago])
    end
    if request.post?
      @data_object.update_attributes(params[:data_object])
      @data_object.locations = params[:locations].map{|id| Location.find(id.to_i)}
      if @data_object.editable
        params[:data_entries].each do |id, entry|
          DataEntry.find(id.to_i).update_attributes(entry)
        end
      end
    end
  end

  def view_location_data
    @location = Location.find(params[:id])
    unless @locations.include?(@location)
      redirect_with_flash("You are not authorized to view this page.", :action => "index")
    end
  end

# Currently not in use -  brs, 8/20/08  
#  def update_location_data
## Note that this action doesn't actually appear anywhere on the admin side;
## This is accessed solely through shift reports. -brs
#    #prepare_data
#    @location = Location.find(params[:id])
#    @object_groups = @location.data_objects.group_by(&:data_type_id)
#    @data_entries = []
#    if request.post? 
#      params[:data_entries].each do |entry|
#        unless entry.empty?
#          DataEntry.create(entry)
#        end
#      end
#    end
#  end
  
  def create_data_type
    unless department_admin?
      flash[:big_notice] = "You are not authorized to view this page."
    end
    if request.post?
      DataType.create!(params[:data_type])
      redirect_with_flash("New data type created", :action => "index")
    end
  end
  
  def create_data_object
    if request.post?
      DataObject.create!(params[:data_object])
      DataObject.last.locations = params[:locations].map{|id| Location.find_by_id(id) }
      redirect_with_flash("New data object created", :action => "index")
    end
  end
  
  def delete_data
    @data_types = @department.data_types
    @objects = @locations.collect(&:data_objects).flatten.uniq
    if request.post?
      if department_admin? and params[:deleted_data_types]
        params[:deleted_data_types].each {|dt| DataType.find(dt).destroy}
      end
      if params[:deleted_data_objects]
        params[:deleted_data_objects].each {|obj| DataObject.find(obj).destroy}
      end
    end
  end

private

end
