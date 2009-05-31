require 'cas_acl'

class ReportController < ShiftController  
  # find_report_or_redirect fetches your current shift report, or redirects you to the shift index because
  # you don't have one. Not called in create or view because you don't have to be signed
  # in for those. ~Ahmet
  before_filter :fetch_report_or_redirect, :except => [:create, :view, :admin_submit, :mark_as_payform_added, :view_float]
  
  def controller_name
    ShiftController.controller_name
  end

  def index 
    #view prints line items, with buttons to add/delete/edit when applicable. ~Ahmet
    fetch_stickies
  end
  
  def create
    # creates the shift report, starting now. adds the login line item.
    @shift = Shift.find_by_id(params[:shift_id])
    if @shift.nil?
      redirect_with_flash('invalid shift id')
        
    # does this shift belong to user
    elsif @shift.user != get_user
      redirect_with_flash('That shift does not belong to you!',
        :controller => "shift", :action => "index")
        
    # is this shift signed into
    elsif @shift.signed_in?
      redirect_with_flash('That shift report has already been signed into!',
        :controller => "shift", :action => "index")
        
    elsif @shift.has_passed? and @shift.scheduled?
      redirect_with_flash('That shift is in the past!',
        :controller => "shift", :action => "index")
        
    # does the user have another shift active
    elsif ShiftReport.find_current_report(@shift.user)
      redirect_with_flash('You\'re already signed into a shift',
        :controller => "shift", :action => "index")
        
    # creates the shift report, starting now. adds the login line item.
    elsif @shift.sub and @shift.sub.start==@shift.start
      redirect_with_flash("You have to cancel your sub for this shift time first before you can sign in.  You can sub the later part of the shift though.", 
        :controller => 'shift')
    else
      ShiftReport.create(:start => Time.now, :shift_id => @shift.id) do |s|
        s.check_ip(request)
      end
      
      redirect_to :action => :index
    end
  end
  
  def submit
    report_check = params[:id]
    unless report_check == @shift_report.id.to_s
      # checks to make sure we're still on the relevant shift
      redirect_with_flash("That submit link is obselete. Are you sure it was the right shift?") and return
    end
    # attempts to submit report, then redirects based on result
    # shift_report.submit already checks to see if report has already been submitted
    @shift_report.check_ip(request, submit = true)
    
    if @shift_report.submit      
      if (payform = add_to_payform(@shift_report))
        #flash[:notice] = "Shift report submitted and payform updated."
        #redirect_to :controller => "/payform/interface",
        #      :action => "add_old",
        #      :url => url_for(:controller => '/report', :action => 'view', :id => @shift_report),
        #      :date => @shift_report.end.strftime("%Y-%m-%d"),
        #      :creator => "New Shifts",
        #      :category => 5,
        #      :total => payform.hours.round.to_i,
        #      :comments => payform.description 
        flash[:notice] = "Shift report submitted and payform updated."
        # redirect_with_flash "Report submitted! <pre>#{email.encoded}</pre>", :action => "view", :id => @shift_report.id #debugging purpose
      else
        @shift_report.payform_auto_added = false
        @shift_report.save
        flash[:big_notice] = "ERROR: This shift report's hours could not be added to payform. Please add your hours manually."        
      end      
      email = ShiftMailer.create_mail_report(@shift_report) #content_type is text/plain
      ShiftMailer.deliver(email)
      
      redirect_to :action => "view", :id => @shift_report
    else
      redirect_with_flash("This shift has already been submitted")
    end
  end
  
  def view
    view_report #defined in shift_application_controller.rb
  end
  
  def view_float
    (@shift_report = find_params_id(ShiftReport)) || return    
    render :template => 'report/view_float', :layout => false 
  end
  
  def line_edit
    #checks for can_edit, edits & adds [edited at ....] tag, saves.
    find_department
    if @department.shift_configuration.report_can_edit == true
      line = LineItem.find(params[:id])
      @oldtext = line.line_content
      if request.post?
        unless line.can_edit?
          redirect_with_flash("This line cannot be edited")#default action is index
        else
          line.line_content = params[:linetext] + " [edited at #{Time.now.strftime("%I:%M%p")}]"
          line.save!
          redirect_to(:action => "index")
        end
      end
    else
      redirect_with_flash("Line item editing has been disallowed 
      by your administrator.", :back)
    end
  end

  def line_delete
    # deletes editable line or warns that it can't be.
    # the request.post? check could be removed, but feels like it'll help prevent accidental deletion. ~Ahmet
    find_department
    if @department.shift_configuration.report_can_edit == true
      if request.post?
        line = LineItem.find(params[:id])
        unless line.can_edit?
          redirect_with_flash("This line cannot be edited")
        else
          begin
            line.destroy
            flash[:notice] = "line '#{line.line_content}' deleted"
          rescue Exception => e
            flash[:notice] = e.message
          end
        end
      end
      redirect_to(:action => "index")
    else
      redirect_with_flash("Line item editing has been disallowed 
        by your administrator.", :back)
    end
  end
  
  def sticky_add
    fetch_stickies
    @sticky = Sticky.new(params[:sticky])
    @options_flag = params[:get_options] || params[:options]
    if @options_flag
      @location_groups = @location_group.department.location_groups.select { |lg| lg.allow_view? @user }
      @locations = @location_groups.map { |group| group.locations }.flatten!
    end
    if request.post?
      if params[:create]
        @sticky = Sticky.make(params[:sticky])
        @sticky.author = @user
        if @options_flag
          @sticky.locations = params[:locations]
          @sticky.location_groups = params[:location_groups]
        else
          @sticky.locations = [@location.id]
        end
        redirect_with_flash("Sticky created") if @sticky.save
      end
    end
  end
  
  def sticky_remove
    fetch_stickies
    sticky = Sticky.find params[:id]
    unless sticky.authorized?(@user) or sticky.authorized?(@location) or sticky.authorized?(@location_group)
      redirect_with_flash("You are not authorized to remove this sticky") and return
    end
    
    unless sticky.active?
      redirect_with_flash("That sticky has already been removed by #{sticky.remover.name} at #{sticky.end_time}") and return
    end
    
    redirect_with_flash("Sticky successfully removed") if sticky.remove(@user)
    sticky.save
  end

  def update_statuses
    @shift_report = ShiftReport.find(params[:id])
    if @shift_report.shift.location.data_objects.empty?
      redirect_with_flash("Your current location does not have any data objects", :action => "index")
    end
    if @shift_report.shift.user != get_user or @shift_report.shift.submitted?
      redirect_with_flash('You are not signed into an appropriate shift.',
        :controller => "shift", :action => "index")    
    end
    @object_groups = @shift_report.shift.location.data_objects.group_by{|obj| obj.data_type_id}
    if request.post?
      if params[:data_entries]
        params[:data_entries].each do |entry|
          new_entry = DataEntry.new(entry)
          unless new_entry.empty?
            new_entry.save!
            content = []
            entry.each_pair do |key, value|
              unless value.blank?
                unless key == "data_object_id"
                  content <<  (new_entry.data_object.data_type[(key + "label")]).to_s +
                    ": " + value.to_s
                end # close unless key ==
              end # close unless value.blank?
            end # close entry.each_pair do
            @shift_report.line_add(new_entry.data_object.name + " -- " + content.join(", "))        
          end # close unless new_entry.empty?
        end #close params.each do
      end # close if params
      redirect_to :action => 'index'
    end # close if post
  end
  
  def add_line_item
    #changed name from line_add to reduce confusion with line_add in shift_report.rb
    if request.post?
      report_check = params[:shift_report_id]
      unless report_check == @shift_report.id.to_s
        # checks to make sure we're still on the relevant shift
        redirect_with_flash("That add link is obselete. Are you sure it was the right shift? " + @shift_report.id.to_s + "  " + report_check) and return
      end
      # adds the :line_content parameter to the report as a line item, with 
      #time=now and editability passed by can_edit. using/receiving can_edit 
      #like this feels safe, since any item the user adds should be editable. 
      #~Ahmet
      @shift_report.check_ip(request)
      if params[:line_content] == ""
        redirect_to :action => "index" and return
      end
      unless @shift_report.line_add(params[:line_content], true)
        redirect_with_flash "Error occurred.  Line not added.", :controller => "report", :action => "index" and return
      end
      #file_cluster_ticket if params[:file_cluster_ticket]
      respond_to do |format|
        format.html {redirect_to :controller => "report", :action => "index"}
        format.js
      end
    end
  end 

  def mark_as_payform_added
    report = ShiftReport.find_by_id params[:id]
    report.payform_auto_added = true
    report.save
    redirect_to :back
  end
#This action is currently on hold;for now we're linking directly to cluster support's
#manual ticket creation page.
#
#  def file_cluster_ticket
##    @shift_report = ShiftReport.find(params[:id])
#    ClusterTicket.new
#    if request.xhr?
#      render :update do |page|
#        if params[:display_cluster_ticket]
#          page.replace_html "cluster_ticket", :partial => "cluster_ticket_form", :object => @shift_report
#          page.visual_effect :toggle_blind      
#        end
#      end
#    end
##    respond_to do |format|
##      format.html { redirect_to :index_unajaxed }
##      format.js
##    end
##    raise "penguins"
#    if request.post?
#      if params[:cluster_ticket]
#        content = params[:cluster_ticket][:machine] + ": " + 
#          params[:cluster_ticket][:status] + "\n" + params[:cluster_ticket][:title]
#        @shift_report.line_add(content, false)
#      end
#    end
#  end

  def update_message_center
    fetch_stickies
  end

  protected 
    
  def add_to_payform(shift_report)
    user = shift_report.shift.user
    department = shift_report.shift.location.location_group.department
    payform = Payform.find_or_create(Date.tomorrow.cweek, Date.tomorrow.year, user, department)
    hours = (((shift_report.end - shift_report.start) / 3600.0)*100).to_i / 100.0
    hours = 0.01 if hours < 0.01
    description = shift_report.short_display
    
    if payform.printed?
      flash[:notice] = "Payform already printed. Can't add to payform."
      return false
    end
    
    begin
      payform_item = PayformItem.new(
        :active => true,
        :hours =>  hours,
        :description => description,
        :date => shift_report.end.to_date,
        :added_by => "shift##{shift_report.id}",
        :department_id => department.id,
        #TODO: we might want to change this to hard-code which category it gets dropped into
        :category_id => Category.find(:first, :conditions => ["name like :name and department_id = :department_id", {:name => "%shifts%", :department_id => department.id}]).id
      )
      payform.payform_items << payform_item
  
      if payform_item.save
        payform.unsubmit if payform.submitted?
        payform.save!
        return payform_item
      else
        return false
      end
    rescue
      return false
    end
  end 


  
  private
  
  def fetch_report_or_redirect
    @user = get_user
    @shift_report = ShiftReport.find_current_report(@user) 
    unless @shift_report
      redirect_with_flash("You are not signed into a shift.",
        :controller => "shift", :action => "index")
    end
  end
  
  def fetch_stickies
    find_department
    @stickies = Sticky.fetch_authorized_active(@department,@location_group,@location,@user)
    @announcements = Announcement.active(@department)
  end
  

  
  def find_department
    @location = @shift_report.shift.location
    @location_group = @location.location_group
    @department = @location_group.department
  end

end
