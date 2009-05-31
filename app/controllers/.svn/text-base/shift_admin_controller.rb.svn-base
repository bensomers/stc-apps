require "date"
class ShiftAdminController < ShiftApplicationController
  before_filter :set_navbar

  helper_method :department_admin?

  #OPTIMIZE: HAVE TO CLEAN THIS UP.  Actually strictly speaking, before_filter is not meant for sharing variables.
  #also, because of ajaxing, we don't want before_filter on ajax action if unnecessary -H
  before_filter :fetch_data
  before_filter :fetch_schedule_view_variables
  # after_filter :delete_user_permission_cache, :only => [:edit_location_group, :delete_location_group, :manage_location_groups]

  layout "shift"

  def index
    view_schedule
  end

  def view_work_hours
    unless params[:group_name].blank?
      @groups = Group.find(:all, :conditions => ['name LIKE ?', "%#{params[:group_name]}%"])
      @users = @groups.collect{|group| group.users.active}.flatten.uniq
      params[:search] = nil
    else
      @users = @department.users.active.search(params[:search])
    end
    week_date = params[:date].blank? ? Date.today : Date.parse(params[:date])
    #default is to get 7 days in the week, any list of days can be passed here
    @week_days = get_week week_date

    @from = Date.parse(params[:from]) rescue @week_days.first
    @to = Date.parse(params[:to]) rescue @week_days.last
    @week_days[0] = @from
    @week_days[-1]= @to
    @dept_work_hours = {}
    @all_work_hours = {}

    config = @department.shift_configuration
    from_time = @from + config.start.minutes
    to_time = @to + config.end.minutes

    @users.each do |u|
      s = u.shifts.all_between(from_time, to_time)
      @dept_work_hours[u.id] = s.filter_by_department(@department).collect(&:duration).sum/3600
      @all_work_hours[u.id] = s.collect(&:duration).sum/3600
    end
  end

  def view_logged_in_shifts
    @current_reports = ShiftReport.all_unsubmitted
    @current_reports = @current_reports.select {|report| @location_groups.include? report.shift.location.location_group}
    @current_reports = @current_reports.sort_by { |report| report.shift.location.short_name }
  end

  def view_unscheduled_shifts
    # views unscheduled reports since time
    @start_date = 1.week.ago
    @end_date = Date.current
    if request.post?
      @start_date = Date.from_select_date(params[:start])
      @end_date = Date.from_select_date(params[:end])
    end
    @unscheduled_shifts = Shift.unscheduled.reject{|s|
      s.shift_report.nil? or s.shift_report.end.blank? or not (@locations.include?(s.location) and
      @start_date <= s.date and s.date <= @end_date)}
  end

  def manage_locations
    @all_locations = @location_groups.collect(&:locations).flatten
    @unassigned_locations = Location.find_all_by_location_group_id(nil)
    @location = Location.new(params[:location])
    if request.post? and @location.save
      redirect_with_flash("Location successfully created", :action => :manage_locations)
    end
  end

  def edit_location
    @location = Location.find(params[:id])
  rescue Exception => e
    flash[:notice] = e.message
  else
    if request.post?
      @location.update_attributes(params[:location])
      begin
        @location.save!
      rescue Exception => e
        flash[:notice] = e.message
      else
        redirect_with_flash("Location successfully updated", :action => :manage_locations)
      end
    end
  end

  def delete_location
    begin
      @location = Location.find(params[:id])
    rescue Exception => e
      flash[:notice] = e.message
    else
      if request.post?
        @location.destroy
        redirect_with_flash("Location successfully deleted", :action => :manage_locations)
      end
    end
  end

  def manage_location_groups
    @location_group = LocationGroup.new(params[:location_group]) do |lg|
      lg.department_id = session["current_chooser_choice"][controller_name]
    end
    if request.post? and department_admin?
      if @location_group.save
        @location_group.reload #this is to load the roles of each permission properly, without this it wont work
        @user.roles += @location_group.permission_view.roles + @location_group.permission_signup.roles + @location_group.permission_admin.roles
        @user.save!
        redirect_with_flash("Location Group #{@location_group.short_name} successfully created",
                              :action => :manage_location_groups)
      end
    end
  end

  def edit_location_group
    begin
      @location_group = LocationGroup.find(params[:id])
    rescue Exception => e
      redirect_with_flash(e.message)
    else
      if request.post?
        if @location_group.update_attributes(params[:location_group])
          redirect_with_flash("Location group successfully updated", :action => :manage_location_groups)
        else
          redirect_with_flash("Problem updating location group #{@location_group.id}")
        end
      end
    end
  end

  def delete_location_group
    begin
      @location_group = LocationGroup.find(params[:id])
    rescue Exception => e
      redirect_with_flash(e.message)
    else
      if request.post?
        begin
          for loc in @location_group.locations
            loc.location_group_id = nil
            loc.save!
          end
        rescue Exception => e
          redirect_with_flash(e.message)
        else
          @location_group.destroy
          redirect_with_flash("Location_group successfully deleted", :action => :manage_location_groups)
        end
      end
    end
  end

  def manage_templates
    @shift_templates = @department.shift_templates.sort_by(&:name) # ShiftTemplate.find_by_department(@department).sort_by(&:name)
    @time_templates = @department.time_templates.sort_by(&:name)
    @library = Library.new_template(params[:library])
    @library.department = @department
    if request.post?
      begin
        @library.save!
      rescue Exception => e
        flash[:notice] = e.message
      else
        redirect_with_flash("Template successfully created", :action => :manage_templates)
      end
    end

  end
  
  def switch_publicly_modifiable
    @library = Library.find(params[:id])
    @library.publicly_viewable = (not @library.publicly_viewable)
    if @library.save
      redirect_with_flash("template successfully switched to #{@library.publicly_viewable ? "public" : "private"}", :action => :manage_templates)
    else
      redirect_with_flash("error during public/private switch!", :action => :manage_templates)
    end
  end

  def edit_template
    if params[:library] and params[:library][:items_to_create] and params[:shift_template_item]
      params[:library][:items_to_create][:user_name] = params[:shift_template_item][:user_name]
    end

    template_hash = params[:library] || {}

    # @granularity = @department.shift_configuration.granularity
    @library = Library.find(params[:id])
    @new_item = @library.new_item(template_hash[:new_item])
    @template_items = split_to_locations(@library.items_with_validate)
    @minutes = (0...60).step(@dept_gran)
    
    @templates = case (@library.class.to_s)
    when "TimeTemplate"
      @template_type_string = "time"
      @department.time_templates
    when "ShiftTemplate"
      @template_type_string = "shift"
      @department.shift_templates
    else
      raise "Unexpected type of Library for #{@department.name}"
    end
    
    if request.post?
      
      # update & delete items as chosen
      items_hash = params[:template_items]
      @locations.each do |location|
        @template_items[location.id].each do |item|
          item.update_attributes(items_hash[item.id.to_s])
          item.destroy if item.delete == "1"
        end
      end
      
      # update library name and description
      @library.update_attributes(template_hash)
      
      #import from other template if anything is selected from drop down
      unless params[:template_to_import_from][:id] == "" 
        @library_to_import_from = Library.find(params[:template_to_import_from][:id])
        @library.import_items_from(@library_to_import_from)
      end
      
      redirect_with_flash("Template Updated", :action => :edit_template, :id => params[:id])
    end
  end


  def delete_template
    begin
      @library = Library.find(params[:id])
    rescue Exception => e
      redirect_with_flash(e.message)
    else
      if request.post?
        @library.destroy
        redirect_with_flash("Template successfully deleted", :action => :manage_templates)
      end
    end
  end


  def activate_templates
    #takes shift and time templates and creates shifts and timeslots out of their items
    @shift_templates = @department.shift_templates # ShiftTemplate.find_by_department(@department).sort_by(&:name)
    @time_templates = @department.time_templates TimeTemplate.all.sort_by(&:name)
    info = " "
    @start_date = Date.from_select_date(params[:start])
    @end_date = Date.from_select_date(params[:end])
    if request.post?
      begin
        TimeSlot.transaction do
          unless params[:time_template][:id] == ""
            time_template = TimeTemplate.find(params[:time_template][:id])
            if time_template.authorized?(get_user)
              if params[:wipe_times]
                TimeSlot.wipe(time_template.locations,
                  @start_date + @department.shift_configuration.start.minutes,
                  @end_date +@department.shift_configuration.end.minutes)
              end #end if params[:wipe]
              for date in @start_date..@end_date
                time_template.time_template_items.each do |item|
                  raise item.to_yaml unless item.class == TimeTemplateItem
                  vars = item.apply_to_date(date)
                  slot = TimeSlot.make(vars) if vars
                  slot.save! if slot
                end # end item do
              end # end date loop
              info << " Time template applied. "
            else
              info << " You are not authorized to apply this time template. "
            end
          end # end unless statement
        end # close timeslot transaction

        Shift.transaction do
          unless params[:shift_template][:id] == ""
            shift_template = ShiftTemplate.find(params[:shift_template][:id])
            if shift_template.authorized?(get_user)
              if params[:wipe_shifts]
                  Shift.wipe(shift_template.locations,
                  @start_date + @department.shift_configuration.start.minutes,
                  @end_date + @department.shift_configuration.end.minutes)
              end
              for date in @start_date..@end_date
                shift_template.shift_template_items.each do |item|
                  vars = item.apply_to_date(date)
                  shift = Shift.make(vars) if vars
                  shift.save! if shift
                end
              end
              info << " Shift template applied. "
            else
              info << " You are not authorized to apply this shift template. "
            end
          end
        end # close shift transaction

      flash.now[:notice] = info
      #rescue Exception => e
      #  flash[:notice] = e.message + "##" + info
      end # end of begin statement
    end # of if...post
  end

  #update or cancel shift
  def edit_shift
    @shift = Shift.find_by_id params[:id]

    if @shift.nil?
      redirect_with_flash "Invalid shift id (possibly because you switched department)"
      return
    end

    if (@shift.location.location_group.department!=@department)
      flash[:big_notice] = "ERROR: Trying to edit shift in #{@shift.location.location_group.department.name} but session's indicating #{@department.name}"
      redirect_to :action => 'index'
      return
    end

    if request.post? and @shift
      if params[:update_button] and @shift.update_attributes(params[:shift])
        redirect_with_flash "Shift updated", :action => :index, :date => @shift.shift_date, :anchor => @shift.shift_date
      elsif params[:delete_button]
        @shift.sub.destroy if @shift.sub #also delete sub
        @shift.destroy #note: because destroy does not return true or false, rather the object @shift itself
        redirect_with_flash "Shift deleted (sub also deleted if exists for this shift). ", :action => :index, :date => @shift.shift_date, :anchor => @shift.shift_date
      end
    end
    sc = get_department.shift_configuration
    dept_start = @shift.start.midnight + sc.start.minutes
    dept_end = @shift.start.midnight + sc.end.minutes

    @time_choices_select = time_select_for(dept_start, dept_end)
    @location_select = @locations.collect {|loc| [loc.long_name, loc.id]}
    # @user_select = User.all.collect { |u| [u.name, u.id] }
  end

  def power_sign_up
    @shift = Shift.new(params[:shift])
  rescue Exception => e
    redirect_with_flash e.message, :action => :power_sign_up
  else
    y params
    @location_select = @locations.collect {|loc| [loc.long_name, loc.id]}
    # @user_select = User.all.collect { |u| [u.name, u.id] }
    @time_choices_select = get_department.shift_configuration.minute_blocks.map{|m| [m.min_to_am_pm, m]}
    if request.post? and params[:commit]=="Power sign up"#only save if the request if post
      params[:shift][:start] = @shift.date + params[:start_in_minute].to_i.minutes
      params[:shift][:end] = @shift.date + params[:end_in_minute].to_i.minutes
      @shift = Shift.make params[:shift] #make does the shift merging if possible (see shift.rb)
      if @shift.save
        redirect_with_flash("Shift signed up successfully: #{@shift.short_display}", :action => :index, :date => @shift.date, :anchor => @shift.date) and return
      end
    end
  end

  def config
    unless department_admin?
      flash[:big_notice] = "You are not authorized to view this page."
      redirect_to :action => "index" and return
    end
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :config, :id => @department.id and return
    end
    @config = @department.shift_configuration
    @time_choices_select = (0..1440).step(@config.granularity).map{|t| [t.min_to_am_pm, t]}
    if params[:shift_configuration]
      if @config.nil?
        @config = ShiftConfiguration.new(params[:shift_configuration])
        @department.shift_configuration = @config
      end
      if @config.update_attributes(params[:shift_configuration])
        @config.calibrate_time
        flash.now[:notice] = "Configuration saved"
      end
    end
  end

  def view_missed_shifts
    unless params[:group_name].blank?
      @groups = Group.find(:all, :conditions => ['name LIKE ?', "%#{params[:group_name]}%"])
      @users = @groups.collect(&:users).flatten.uniq
      params[:search] = nil
    else
      @users = @department.users.search(params[:search])
    end
  end

  def report_links
    @link_group_select = []
    @link_group_select.push([@department.name, "department" + @department.id.to_s]) if department_admin?
#    @link_group_select.push(["----------", nil])
    @link_group_select = @link_group_select|(@location_groups.map{|lg|[lg.short_name, "lg" + lg.id.to_s]})
#    @link_group_select.push(["----------", nil])
    @link_group_select = @link_group_select|(@locations.map{|loc|[loc.short_name, "loc" + loc.id.to_s]})
    if request.post?
      if params[:new_link]
        if params[:new_link][:link_group].delete!("department")
          dept = Department.find(params[:new_link][:link_group])
          dept.useful_links << ',<a href=' + params[:new_link][:url] + ">" +
            params[:new_link][:label] + "</a>"
          dept.save!
        end
      end

      if params[:links][:dept]
        dept = Department.find(params[:links][:dept])


      end

    end
  end

  def admin_submit_report
    @shift_report = ShiftReport.find(params[:id])
    @shift_report.check_ip(request, submit = true, get_user.name)
    unless @shift_report.submit
      redirect_with_flash("This shift has already been submitted", :action => "index")
    else
      #ADMIN SUBMIT SHOULD NOT ADD TO PAYFORM
      @shift_report.payform_auto_added = false
      @shift_report.save

      email = ShiftMailer.create_mail_report(@shift_report) #content_type is text/plain
      ShiftMailer.deliver(email)

      redirect_with_flash("Report submitted by admin.", :controller => "report", :action => "view", :id => @shift_report)
    end
  end
# =======================================
# = Other public methods, without views =
# =======================================

#These are for some reason required for Nathan, but not Harley
#The URLs are being recognized as actions instead of controllers -N

  def restrictions
    redirect_to :controller => "/shift_admin/restrictions",
                :id => session["current_chooser_choice"][self.controller_name]
  end

  def announcements
    redirect_to :controller => "/shift_admin/announcements",
                :id => session["current_chooser_choice"][self.controller_name]
  end

  def calendar
    redirect_to :controller => "/shift_admin/calendar",
                :id => session["current_chooser_choice"][self.controller_name]
  end

  def time_slots
    redirect_to :controller => "/shift_admin/time_slots",
                :id => session["current_chooser_choice"][self.controller_name]
  end

protected

  #@user and @department may not be avaible first because it's called as a helper method which may bypass before_filter
  #that's why i added get_user and get_department
  def department_admin?
    return (@user||get_user).authorized?("shift_admin/@" + (@department||get_department).name.decamelize + "/department_admin")
  end

private

  def fetch_data
    @user = get_user
    @department = get_department
    @location_groups = @department.location_groups.select {|lg| lg.allow_admin? @user}
    @locations = @location_groups.collect {|g| g.locations.active }.flatten
  end

  def set_navbar
    left_nav("shift_admin")
  end


end
