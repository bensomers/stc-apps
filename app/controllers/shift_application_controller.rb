require 'cas_acl'
class ShiftApplicationController < ApplicationController
  # Check authentication with CAS login 
  before_filter CASACL::CASFilter
  before_filter :chooser
  
  helper_method :render_to_string #this allow calling render_to_string from the view and helper. -H
  helper_method :fetch_location_groups
  helper_method :pref_filter
  helper_method :time_select_for
  helper_method :min_block

  def view_schedule
    @user = get_user
    @department = get_department
    @loc_groups_all ||= fetch_location_groups
    @loc_groups = pref_filter(@loc_groups_all)
        
    week_date = params[:date].blank? ? Date.today : Date.parse(params[:date])

    #default is to get 7 days in the week, any list of days can be passed here
    @week_days = get_week week_date    
  end
  
  def sign_up
    @shift = Shift.new(params[:shift]) #using form_for
    unless (@shift.start and @shift.end and @shift.location_id)
      redirect_with_flash "Sign up link called incorrectly" and return
    end
    
    orig_start = Time.parse(params[:orig_start]) rescue @shift.start
    orig_end = Time.parse(params[:orig_end]) rescue @shift.end
    
    @time_choices_select = time_select_for(orig_start, orig_end)    
      
    if from_admin?
      location_groups = get_department.location_groups.select {|lg| lg.allow_admin? @user}    
      locations = location_groups.collect {|g| g.locations.active }.flatten

      @location_select = locations.collect {|loc| [loc.long_name, loc.id]}
      
      #not needed anymore
      # @user_select = User.all.collect { |u| [u.name, u.id] }      
    end

    #id of the div that contains quick sign up form
    div_id = @shift.sign_up_div

    #even ajax request should still be post if it requires making changes
    if request.post? and (@shift.ok_to_sign_up? or from_admin?)      
      #make does the shift merging if possible (see shift.rb)
      @shift = Shift.make(params[:shift])
      if @shift.errors.empty? and @shift.save
        respond_to  do |format|
          format.html do
            redirect_with_flash("Shift signed up successfully", :action => :index, :date => @shift.shift_date, :anchor => @shift.shift_date)
          end
          format.js do
            render :update do |page|
              page[div_id].visual_effect :blind_up, :duration => 0.2              

              page.replace_html @shift.parent_div, :partial => 'shift/schedule/fetch_day', :object => @shift.shift_date
              page[@shift.parent_div].visual_effect :highlight, :startcolor => "#104E8B", :endcolor => "#ffffff"
              
              if !is_admin?
                page.replace_html('upcoming_shifts_div', :partial => 'upcoming_shift_layout')
                page['upcoming_shifts_div'].visual_effect :highlight, :startcolor => "#104E8B", :endcolor => "#ffffff"
              end
            end
          end
        end
        return
      end
    end
    
    respond_to do |format|
      format.html do
        render :template => 'shift/sign_up' #shift admin and shift loads the same page
      end
      format.js do
        render :update do |page|          
          page.replace_html div_id, :partial => "quick_sign_up"
          if @shift.errors.empty?
            page[div_id].hide
            page[div_id].visual_effect :blind_down, :duration => 0.2
          end
        end
      end
    end
  end

  #Sign in to a shift given an id from url.
  def sign_in
    @shift = Shift.find(params[:id])
    unless (from_admin? or (@shift.user == @user))
      redirect_with_flash("That shift does not belong to you.") and return
    end
    
    #id of the div that contains quick sign up form
    div_id = @shift.sign_in_div
    respond_to do |wants|
      wants.html {}
      wants.js do
        render :update do |page|
          page.replace_html div_id, :partial => "quick_sign_in"
          page[div_id].hide
          page[div_id].visual_effect :blind_down, :duration => 0.2
        end
      end
    end
  rescue Exception => e
    redirect_with_flash(e.message) and return
  else
    #if one tries sign_in to a submitted shift report.Whether to show submitted shifts is up for discussion (tell me). -H
    if @shift.submitted?
      redirect_with_flash("You have already submitted this shift report!") and return
    end
    
    #preventing user to sign in to a shift that has passed
    if (@shift.has_passed? and @shift.scheduled?)
      redirect_with_flash("Too late. Can't sign in to a shift that has passed.")and return
    end
    
    render :template => 'shift/sign_in' if from_admin?
  end
    
  #for Shift_Admin and Report
  def view_report
    (@shift_report = find_params_id(ShiftReport)) || return
    redirect_to :controller => :report if (!@shift_report.submitted? and @shift_report.shift.user == get_user)
  end

  #for use in Shift and ShiftAdmin
  def sub_request
    (@shift = find_params_id(Shift)) || return
    
    @sub = Sub.new(params[:sub]) do |s|
      s.bribe_start = s.bribe_end = nil unless s.bribe_flag=="1"
    end
      
    @sub.shift = @shift #sub belongs to a shift
    @sub.user = @shift.user #sub belongs to requestor, need this bcoz if parent shift is deleted, still can track user    

    #need to map time_choices to the following to use in the view page. -H
    @time_choices_select = time_select_for(@shift.start, @shift.end)
    if request.post? #if request is submitted and max not reached
      @sub.email_to = @shift.location.location_group.sub_email #request email when offer_to is blank (ALL)      
      offered_names = []
      
      unless @sub.offer_to.blank? #if specific login_or_name_list are entered, email these people separately
        login_or_name_list = @sub.offer_to.split(',').reject {|n| n.blank?} #delete all nil/empty elements from the array.
        unless login_or_name_list.empty?
          @sub.email_to = [] #prepare list of emails
          login_or_name_list.each do |login_or_name|
            login_or_name.strip! #remove leading, trailing space. (very impt)
            user = User.find_by_login(login_or_name) || User.find_by_name(login_or_name)
            if user.nil?
              @sub.errors.add(:offer_to, "invalid netid or name: #{login_or_name}")
            else
              @sub.add_eligible(user)
              @sub.email_to << user.email
              offered_names << user.name
            end
          end
        end
      end
      
      @allowed = (from_admin? || !@sub.exceed_max?(add_public_sub = offered_names.empty?))
      
      #check errors first to make sure all names were entered correctly
      if @sub.errors.empty? and @sub.save
        email = ShiftMailer.create_send_request(@sub, 
            url_for(:controller => 'shift', :action => 'sub_accept', :id => @sub) )
        ShiftMailer.deliver(email)
        offered_names = ['everybody'] if offered_names.empty?
        redirect_with_flash "Sub requested, sent to #{offered_names}", :action => :index, :date => @shift.shift_date, :anchor => @shift.shift_date
        
        #comment this line and uncomment above deliver email line if you want to have emails sent
        #render(:text => '<pre>' + email.encoded + '</pre>') #debugging purpose
      end      
    end
  end
  
  #action to cancel a shift request, redirect to index so no view file is needed. -H
  def sub_cancel
    (@shift = find_params_id(Shift)) || return
    #only user can cancel his own sub request or admin can cancel anybody's sub request
    if request.delete? and (from_admin? or (@shift.user == get_user))
      #somehow @shift.sub.destroy shortcut does not work properly
      s = @shift.sub
      s.destroy
      @shift.save
      redirect_with_flash "Sub request cancelled.", :action => :index, :date => @shift.shift_date, :anchor => @shift.shift_date
    else
      redirect_with_flash 'Illegal URL call'
    end
  end

  def view_preferences
    pref = get_user.preference
    
    all_ids = fetch_location_groups.collect{|lg| lg.id.to_s}

    #only update show/hide pref if there are more than one options for user
    #bcoz if user can only see one location group, this pref is not shown    
    pref.set_hidden_groups(all_ids - (params[:show_groups] || [])) if all_ids.size > 1
    
    #a bit convoluted, but this is so that later we can customize further (like specific days csv), not just 'all'
    pref.show_bars = params[:show_bars]=='all'
    
    pref.save!
    redirect_to :action => :index, :date => params[:date]
  end
  
  def chooser_options
    { "choices" => get_departments,
      "required" => true }
  end
    
  protected
  # splits an array of objects into locations by location ID, 
  def split_to_locations(objects)
    hash = {}
    for object in objects
      if hash[object.location_id]
        hash[object.location.id] << object
      else
        hash[object.location_id] = [object]
      end
    end
    hash.default = [] #for other values not in the hash, it's returned [] instead of nil
    hash
  end
  
   
  #shorter way, but default = [] doesn't work, so need to handle it nil instead of empty? elsewhere -H
  # def split_to_locations(objects)
  #     ordered_hash = objects.group_by(&:location_id)
  # end
  
    
  #generate a list of time choices based on start, end time, and granularity
  def time_select_for(select_start, select_end) #bcoz time_select name is already a rails helper
    #need to map time_choices to am_pm view format and normal time save format -H
    get_time_choices(select_start, select_end, min_block).map {|t| [t.to_s(:am_pm), t]}
  end
  
  #OPTIMIZE: this requires you to return immediately after calling find_params_id if nil is returned, not very neat anyway
  def find_params_id(model)
    model.find(params[:id])
  rescue Exception => e
    redirect_with_flash(e.message) and return nil
  end
  
  def from_admin?
    controller_name=="shift_admin"
  end
  
  def from_shift?
    controller_name=="shift"
  end
  
  def get_time_choices(start_t, end_t, block)
    current = start_t
    choices = [current]
    while (current += block) < end_t
       choices << current
    end
    choices << end_t#note by adding end_t separately, even when granularity does not divide end_t - start_t, still works
  end

  def fetch_location_groups
    @user ||= get_user
    @department ||= get_department
    if from_admin?
      @department.location_groups.select {|lg| lg.allow_admin? @user}
    elsif from_shift?
      @department.location_groups.select {|lg| lg.allow_view? @user}
    else
      raise 'illegal controller!'
    end
  end
  
  def pref_filter(loc_groups)
    @user ||= get_user
    pref = @user.preference || @user.create_preference    
    loc_groups.reject { |e| pref.hide_group?(e) }    
  end
  
  def min_block
    session["min_block"] ||= get_department.shift_configuration.granularity.minutes
  end
  
  def fetch_schedule_view_variables
    sc = get_department.shift_configuration
    @dept_start_hour = sc.start / 60
    @dept_end_hour = sc.end / 60
    @dept_gran = sc.granularity
    session["min_block"] = @dept_gran.minutes
    @blocks_per_day = (sc.end - sc.start) / @dept_gran
    @blocks_per_hour = 60 / @dept_gran
  end  
  
end
