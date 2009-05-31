class PayformController < PayformApplicationController    
  def index
    if params[:payform] #only need to look if params[:id] set
      date = Date.parse(params[:payform][:week])
      week = date.cweek
      year = date.year
    end
    department = get_dept_from_url
    
    week = default_week_unless_already week
    year = default_year_unless_already year

    #find current payform and redirect to view
    current_payform = Payform.find_or_create(week, year, @user, department)
    redirect_with_flash( flash[:notice], :action => :view, :id => current_payform )
  end
  
  def view
    @payform = Payform.find_by_id params[:id]
    @unpayformed_reports = ShiftReport.payform_not_auto.select { |r| r.shift.user==@user }
    if @payform and @payform.authorized?(@user, controller_name)
      @department = @payform.department
      session["current_chooser_choice"][controller_name] = @department.id
      @dates = get_previous_weeks
      @date = @payform.get_date
      @clock = Clock.find_or_create(@user, @department)
    else
      redirect_with_flash(params[:id] ? "Invalid Payform" : nil)
    end
  end
  
  def view_all
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :view_all, :id => @department.id and return
    end
    @payforms = @user.payforms.all(:conditions => ["department_id = ?", @department.id])
    @payforms.sort! {|a,b| a.get_date <=> b.get_date}
  end


  def submit
    payform = Payform.find_by_id params[:id]
    if payform and payform.authorized?(@user, controller_name)
      unless payform.submitted
        payform.submitted = Time.now
        flash = payform.save ? "Payform Submitted" : "Error Submitting Payform"
      else
        flash = "Payform Already Submitted" 
      end
      redirect_with_flash flash, :action => :view, :id => payform.id
    else
      redirect_with_flash "Invalid Payform"
    end
  end

  def interface
    redirect_to :action => "index", :id => session["current_chooser_choice"][self.controller_name]
  end
end
