require "date"
class PayformAdminController < PayformApplicationController
  before_filter :set_navbar
  before_filter :chooser
  auto_complete_for :group, :name
  
  def index
    department = get_dept_from_url
    if !params[:id] or params[:id].to_i != department.id
      redirect_to :action => :index, :id => department.id
    else
      redirect_to :action => :show_all, :id => department.id
    end 
  end
  
  
  def view
    @payform = Payform.find_by_id params[:id]
    if @payform and @payform.authorized?(@user, controller_name)
      @department = @payform.department 
      session["current_chooser_choice"][controller_name] = @department.id
      @dates = get_previous_weeks 
      @weeks = @department.payform_configuration.weeks
      if Date.tomorrow.cweek - @payform.week > @weeks and @weeks != 0
        flash.now[:big_notice] = "Payform is more than 4 weeks old." 
        flash.now[:timeout] = 0
        flash.now[:message] = "Warning:"
      end
    else
      redirect_with_flash "Invalid Payform", :action => :index
    end
  end
  
  def show_all
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :show_all, :id => @department.id and return
    end
    @users = @department.users.search(params[:search]).sort_by(&:name)
  end
  
  def live_user_search
    @department = get_dept_from_url
    if request.xhr?
      @users = @department.users.search(params[:search_text]).sort_by(&:name)
    end
    render :partial => params[:partial]
  end
  
  def show_unapproved
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :show_unapproved, :id => @department.id and return
    end
    @payforms = Payform.unapproved(@department.id)
    @payform_users = @payforms.group_by &:user_id
  end
  
  def past_payforms
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :past_payforms, :id => @department.id and return
    end
    @users = @department.users.search(params[:search])
  end

  def approve
    payform = Payform.find(params[:id])
    if payform and payform.authorized?(@user, controller_name)
      if payform.submitted and !payform.approved
        payform.approved_by = @user.id
        payform.approved = Time.now
        if payform.save
          redirect_with_flash "Payform approved.", :action => :show_all, :id => payform.department_id and return
        else
          redirect_with_flash "Error approving payform", :action => :view, :id => params[:id] and return
        end
      else
        redirect_with_flash "Payform status error", :action => :view, :id => params[:id] and return
      end
    end
  end
  
  def print_all_approved
    @department = get_dept_from_url
    @payforms = Payform.unprinted(@department.id)
    admin_user = get_user
    if params[:print_payforms] and request.post?
      begin
        filename = Time.now.strftime("payform_%Y%m%d%H%M%S.pdf")
        flash = PayformPrinter.print_payforms(admin_user, filename, @payforms)
      rescue Exception => e
        @payforms.each do |p|
          p.printed = nil
          p.save
        end
        File.delete("data/payforms/" + filename) if File.exists?("data/payforms/" + filename)
        flash = "Error printing payforms: " + e
      end 
      redirect_with_flash flash, :action => :show_all, :id => @department.id
    elsif params[:print_to_text] and request.post?
      string = ""
      @payforms.each do |p|
        string += "        Name: #{p.user.name}\n"
        string += " Employee ID: #{p.user.ein}\n"
        string += " Total Hours: #{p.total_hours}\n"
        string += " Week ending: #{p.get_date.to_s}\n"
        string += "\n ============ \n"
        
        Category.active(p.department).each do |cat|
          string += ">> #{"%5.2f" % p.category_hours(cat.id)} hours in "
          string += "#{cat.name}\n"
          
          p.payform_items.active.in_category(cat.id).each do |item|
            string += "  + #{"%5.2f" % item.hours} hours on #{item.date.to_s}: "
            string += "#{item.description}\n"
          end
        end
        string += "\n\f"
      end
      send_data string, :type => "text/plain", :filename => "payforms_for_#{Date.today.to_s}.txt"
    end
  end 
    
  def email_reminders
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :email_reminders, :id => @department.id and return
    end
    @default_reminder_msg = @department.payform_configuration.reminder
    @default_warning_msg = @department.payform_configuration.warning
    @default_warn_start_date = 8.weeks.ago
  end
  
  def send_reminders
    @department = get_dept_from_url
    @users = @department.users.active.select {|u| u.email}
    admin_user = get_user
    
    users_reminded = []
    for user in @users
      PayformMailer.deliver(PayformMailer.create_reminder(admin_user, user, params[:post][:body]))
      users_reminded << "#{user.name} (#{user.login})"
    end
    redirect_with_flash "E-mail reminders sent to the following: #{users_reminded.to_sentence}", :action => :email_reminders, :id => @department.id
  end
  
  def send_warnings
    message = params[:post]["body"]
    start_date = Date.parse(params[:post]["date"])
    @department = get_dept_from_url
    @users = @department.users.sort_by(&:name)
    users_warned = []
    @admin_user = get_user
    for user in @users     
      Payform.find_or_create(Date.tomorrow.cweek, Date.tomorrow.at_beginning_of_week.year, user, @department)
      unsubmitted_payforms = (Payform.all( :conditions => { :user_id => user.id, :department_id => @department.id, :submitted => nil }, :order => 'year, week' ).collect { |p| p if p.get_date >= start_date }).compact
      
      unless unsubmitted_payforms.blank?
        weeklist = ""
        for payform in unsubmitted_payforms
          weeklist += payform.get_date.strftime("\t%b %d, %Y\n")
        end
        email = PayformMailer.create_warning(@admin_user, user, message.gsub("@weeklist@", weeklist))
        #TODO: Uncomment the following line
        PayformMailer.deliver(email)
        users_warned << "#{user.name} (#{user.login}) <pre>#{email.encoded}</pre>"
      end
    end
    redirect_with_flash "E-mail warnings sent to the following: <br/><br/>#{users_warned.join}", :action => :email_reminders, :id => @department.id
  end
  
  
  def add_jobs
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :add_jobs, :id => @department and return
    end
    
    if params[:payform]
        @date = Date.parse(params[:payform][:week])
        week = @date.cweek
        year = @date.year
    end
    week = default_week_unless_already week
    year = default_year_unless_already year
    @dates = get_previous_weeks
    @days  = Payform.get_days(year, week)
    
    if params[:payform_item] 
      big_notice = []
      notice = []
      @users_added = []
      selected_users = User.get_selected(params)
      payform_item = PayformItem.new(params[:payform_item])
      if params[:calculate_hours]
        payform_item.hours = get_payform_item_hours
      end
      payform_item.date = params[:date]
      payform_item.added_by = "MassJob: #{@user.login}"
      payform_item.department = @department
      payform_item.mass = true
      selected_users.each do |user|
          payform = Payform.find_or_create(week, year, user, @department)
          payform_item.payforms << payform
          unless payform.printed
              payform.unapprove if payform.approved?
              @users_added << user.name
            else
              big_notice << "Payform already printed for #{user.name}."
          end
      end
      notice << "Job created successfully for the following users: #{@users_added.to_sentence}"
      flash[:big_notice] = big_notice.join('<br/>') unless big_notice.empty?
      unless payform_item.save
        flash[:big_notice] = "The job did not get saved. Please check that you have filled out the fields correctly."
        flash[:message] = "Error:"
        notice = nil
      end
      redirect_with_flash notice, :action => 'add_jobs', :id => @department.id
    end
  end
  
  def view_mass_jobs
    @department = get_dept_from_url
    @general_view = true
    
    
    #temporary code storage space
    
    
=begin


<!--
  <% jobs = @payform.misc_jobs(is_admin?) %>
-->

<!--
  <% jobs = (is_admin? ? @payform.payform_items.in_category(category.id) : @payform.payform_items.in_category(category.id).active) %>
  <% jobs = category.payform_items.mass %>
  or
-->

<!-- for reference -->
<!--
def misc_jobs(admin=false)
    m_jobs = Array.new(self.payform_items)
    for category in Category.active(department.id)
      m_jobs.delete_if { |p| p.category_id == category.id or (department.payform_configuration.show_disabled_cats and p.category)}
    end
    admin ? m_jobs : (m_jobs.compact.collect do |p| p if p.active? end).compact
  end
-->


=end
    
    
    
    
  end
  
  def show_clocks
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :show_clocks, :id => @department.id and return
    end
    if params[:stop_clock] and request.post?
      clock = Clock.find(params[:stop_clock])
      clock.clock_out
      redirect_with_flash "Clock Stopped for #{User.find(clock.user_id).name}", :action => "show_clocks", :id => @department.id
    end
    @clocks = ( @department.clocks.collect { |c| c if c.running } ).compact
  end

    
  def config
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :config, :id => @department.id and return
    end
    @config = @department.payform_configuration
    if params[:payform_configuration] 
      if @config.nil?
        @config = PayformConfiguration.new(params[:payform_configuration]) 
        @department.payform_configuration = @config
      end
      if @config.update_attributes(params[:payform_configuration])
        flash.now[:notice] = "Configurations saved"
      end
    end
  end
  
  #redirect from categories department switcher
  def categories
    redirect_to :controller => "/payform_admin/categories", :action => "index", :id => get_dept_from_url
  end
  
  def mass_clocks
    redirect_to :controller => "/payform_admin/mass_clocks", :action => "index", :id => get_dept_from_url
  end

  def set_navbar
    left_nav("payform_admin")
  end


  
end
