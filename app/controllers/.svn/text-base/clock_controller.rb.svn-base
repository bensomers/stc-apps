require 'cas_acl'
class ClockController < PayformApplicationController
  before_filter CASACL::CASFilter
  
  def index
    @clock = Clock.find_or_create(get_user, get_dept_from_url)
  end
  
  def in
    dept = get_dept_from_url
    clock = Clock.find_or_create(user = get_user, dept)
    if !clock.in and request.post?
      clock.user = user
      clock.department = dept
      clock.clock_in
    end
    redirect_to :controller => "/payform"
  end

  def out
    if (clock = get_user.clock) and clock.in and request.post?
      if clock.seconds > 35 and clock.seconds < 60*60*24
        clock.clock_out
      else
        flash[:notice] = "Time was either too short or too long"
        clock.destroy
      end
    end
    redirect_to :controller => "/payform"
  end
  
  def restart
    if (clock = get_user.clock) and clock.out and request.post?
      
      clock.in = Time.now.in(-clock.seconds)
      clock.out = nil
      clock.save
    end
    redirect_to :controller => "/payform"
  end
  
  def add_job
    if params[:payform_item] and (clock = get_user.clock) and clock.out and request.post?
      unless (description = params[:payform_item][:description]) == ''
        week = default_week_unless_already nil
        year = default_year_unless_already nil
        payform_item = PayformItem.new(
          :hours           => clock.hours ,
          :date            => Date.today,
          :category_id     => params[:payform_item][:category_id],
          :department_id  => get_dept_from_url.id,
          :description     => "(" + clock.start.strftime("%H:%M:%S") + " to " + clock.out.strftime("%H:%M:%S") + "): " + description,
          :added_by        => "Punch Clock") 
        payform = Payform.find_or_create(week, year, get_user, get_dept_from_url)
        if !payform.printed? and payform.unapprove
          payform.payform_items << payform_item
          if payform_item.save
            clock.destroy
            flash[:notice] = "Successfully clocked out."
          else
            flash[:notice] = "Error saving job"
          end
        else
          flash[:notice] = "Current payform has already been printed.  Please address the problem to the payform administrator."
        end
      else
        flash[:notice] = "Please enter a job description."
      end
    end
    redirect_to :controller => "/payform"
  end

  def cancel
    if (clock = get_user.clock) and request.post?
      clock.destroy
    end
    redirect_to :controller => "/payform"
  end
  
  def time
    @clock = get_user.clock
  end

  def controller_name
    PayformController.controller_name
  end

  protected
  
  def round_down(num, nearest= 1)
    num % nearest == 0 ? num + nearest - (num % nearest) : num
  end
end
