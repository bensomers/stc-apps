class StickyController < ShiftController
  
  def controller_name
    ShiftController.controller_name
  end
  
  def index
    @location_groups = fetch_location_groups
    objects = []
    objects << @user
    @location_groups.each do |location_group|
      objects = objects + location_group.locations
      objects << location_group
    end
    objects << @department
    
    @stickies = Sticky.fetch_authorized_active(objects)
  end
  
  def modify
    
  end
end
