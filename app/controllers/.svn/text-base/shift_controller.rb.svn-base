class ShiftController < ShiftApplicationController
  #prepare common variables for all actions
  before_filter :fetch_user_and_department
  before_filter :fetch_schedule_view_variables, :only => [:index, :sign_in, :sign_up]
  #using default layout in layout/shift.html.erb
  
  #main page: display Upcoming Shifts and Shift Schedule of the week
  def index    
    @subs_you_requested = @user.subs.since(Time.now).not_taken.sort_by(&:start)
    @subs_you_can_take = Sub.not_taken.since(Time.now).not_from(@user).select {|s| s.eligible?(@user)}.sort_by(&:start)
    @announcements = Announcement.find_all_by_for_department_id(@department.id)
    @current_report = ShiftReport.find_current_report(@user)# for Return_to_current_report link
    view_schedule
  end


  
  #This creates a new shift for a blank report, then redirect to sign_in. -H
  def sign_in_to_blank
    @department ||= get_department
    #NOTE: this does nothing if the URL request is not a post
    if request.post?      
      if ShiftReport.find_current_report(@user)
        redirect_with_flash "You are already signed into a shift!"
      else
        @shift = Shift.new(:user_id => params[:user_id], :location_id => params[:location_id])
        @shift.end = @shift.start = Time.now
        @shift.save!
        redirect_to :controller => :report, :action => :create, :shift_id => @shift.id
      end
    end
  end
  
  #sub_request and sub_cancel are defined in the parent class ShiftApplicationController
  def sub_accept
    @sub = Sub.find_by_id(params[:id])
    
    msg = (if @sub.nil?
        "Invalid sub id. Maybe sub's been cancelled."
      elsif @sub.taken?
        "Too late.  #{@sub.info} has already been taken."
      elsif !@sub.eligible?(@user)
        "Sub not offered to you or you can't take this shift."
      elsif @sub.has_passed?
        "Time already passed for this sub (ended at #{@sub.end})"
      end)
      
    (redirect_to(:action => :index) and return) if msg
    
    if @sub.user==@user
      redirect_to(:action => :sign_in, :id => @sub.shift) and return 
    end
    
    if @sub.bribe_on?
      @start_select = time_select_for(@sub.bribe_start, @sub.start) if @sub.bribe_start < @sub.start
      @end_select = time_select_for(@sub.end, @sub.bribe_end) if @sub.bribe_end > @sub.end
    end
    
    #user can choose a different sub start,end time if bribe was on
    if request.post?
      if @sub.bribe_on? #temprorarily overwrite sub start end time with user's choice
        @sub.start = Time.parse(params[:start]) if params[:start]
        @sub.end = Time.parse(params[:end]) if params[:end]
      end
      
      old_shift = @sub.shift
      destroy_old_shift_flag = false
      #store a hash of values for new_shift, so that it's called by Shift.sign_up later.  this ensures shift merging correctly
      #and it's logical since we're signing up a shift for somebody else
      new_shift_hash = {:user_id => @user.id, 
                        :location_id => old_shift.location_id, 
                        :start => @sub.start, 
                        :end => @sub.end}

      @sub.new_user = @user.id #pass id of sub taker to sub, new_shift must wait later, see explanation when it's saved.
      
      #break down into 4 cases: sub first part of shift, middle part of shift, last part of shift, or whole shift. -H
      if @sub.start==old_shift.start
        if @sub.end==old_shift.end #sub whole shift            
          destroy_old_shift_flag = true#delete old shift
        else #sub.end < old_shift.end; sub first part of shift
          old_shift.start = @sub.end #update the reduced shift belonging to requester
        end
      else #sub.start > old_shift.start - ie sub starts after orig shift
        if @sub.end < old_shift.end #sub middle part of shift, there is a left over for the old user
          left_over_shift = Shift.new(:user_id => @sub.user_id, :location_id => old_shift.location_id, 
                                      :start => @sub.end, :end => old_shift.end)            
        end
        old_shift.end = @sub.start #update the reduced shift belong to requester          
      end
      
      #save changes, need to use rescue because we need to be able to rollback (eg deleting shifts created below when creating sub fails)
      begin
        Shift.transaction do
          new_shift = Shift.make(new_shift_hash) #create and save new_shift
          new_shift.save!
          old_shift.destroy if destroy_old_shift_flag
          old_shift.save! if old_shift
          left_over_shift.save! if left_over_shift
          @sub.new_shift = new_shift.id #note: id only assigned after new_shift has been saved
          @sub.save!
        end
      rescue Exception => e
        redirect_with_flash e.message, :action => 'sub_accept'
      else
        email = ShiftMailer.create_accept(@sub, User.find(@sub.new_user))
        ShiftMailer.deliver(email)
        redirect_with_flash("Sub is given to you now. Notification email sent. Thanks", :action => 'index', :date => @sub.shift.shift_date)
        #render(:text => '<pre>' + email.encoded + '</pre>') #debugging purpose
      end                  
    end #of <if request.post?>
  end
  
  def preferred_templates
    @location_groups = @department.location_groups.select {|lg| lg.allow_sign_up? @user}    
    @locations = @location_groups.collect {|g| g.locations.active }.flatten
    # action for regular STs to pick template to add preferences to
    @shift_templates = @department.shift_templates.select {|template| template.publicly_viewable} # ShiftTemplate.find_by_department(@department).sort_by(&:name)
  end
  
  def preferred_shifts
    @location_groups = @department.location_groups.select {|lg| lg.allow_sign_up? @user}    
    @locations = @location_groups.collect {|g| g.locations.active }.flatten
    fetch_schedule_view_variables
    if params[:library] and params[:library][:items_to_create] and params[:shift_template_item]
      params[:library][:items_to_create][:user_name] = params[:shift_template_item][:user_name]
    end
    
    template_hash = params[:library] || {}
    
    # @granularity = @department.shift_configuration.granularity
    @library = Library.find(params[:id])
    (redirect_with_flash("That template is not public", :action => :preferred_templates) and return) unless @library.publicly_viewable
    @new_item = @library.new_item(template_hash[:new_item])
    @single_user_only = true # has an effect on template item template
    @template_items = split_to_locations(@library.template_items) #.items_with_validate)
    @minutes = (0...60).step(@dept_gran)
    if request.post?
      items_hash = params[:template_items] || {}
      @locations.each do |location|
        @template_items[location.id].each do |item|
          item.update_attributes(items_hash[item.id.to_s])
          item.destroy if item.delete == "1"
        end
      end
      @library.update_attributes(template_hash)
      redirect_with_flash("Template Updated", :action => :preferred_shifts, :id => params[:id])
    end
  end
  
  def kilroys
    if params[:id] # if we're being called for a particular location
      @location = Location.find(params[:id]) # fetch that one
      @start_date = 1.week.ago.to_date.sunday
      @end_date = Date.current
      if request.post?
        @start_date = Date.from_select_date(params[:start])
        @end_date = Date.from_select_date(params[:end]) + 1
      end
      @shifts = @location.shifts.select{|s|
        s.submitted? and (@start_date <= s.date and s.date <= @end_date)
      }
      @grouped_shifts = @shifts.group_by {|s| s.report.start.sunday_of_week}
    else # if we're being called without any id
      @location_groups = fetch_location_groups # get list of locs to display
    end
  end
  
  private
  def fetch_user_and_department
    @user = get_user
    @department = get_department
  end
  
end
