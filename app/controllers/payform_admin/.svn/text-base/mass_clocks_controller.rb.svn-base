class PayformAdmin::MassClocksController < PayformApplicationController
  before_filter :set_navbar
    
  def index
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => "index", :id => @department and return
    end
    @mass_clocks = MassClock.find_all_by_department_id(@department)
    #TODO: Narrow this down to only mass clocks with either clocks or unprinted jobs.
  end
  
  
  def add_mass_clock
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :mass_clock, :id => @department and return
    end
    if params[:payform_item]
      notice = []
      users_added = []
      time_in = Time.now
      @mass_clock = MassClock.create(params[:payform_item])
      @mass_clock.department = @department
      selected_users = User.get_selected(params)
      for user in selected_users
        user.clock ? user.clock.destroy : nil
        user.clock = Clock.find_or_create(user, @department)
        user.clock.department = @department
        user.clock.mass_clock = @mass_clock
        if user.clock.clock_in(time_in) and @mass_clock.save
          users_added << user.name
        else
          notice << "Error saving clock for #{item.payform.user.name}"
        end
      end
      notice << "Clocked in successfully for the following users: #{users_added.to_sentence}" unless users_added.empty?
      redirect_with_flash notice, :action => "index", :id => @department
    else
      @mass_clock = MassClock.new
    end
  end
  
  def add_users_mass_clock
    @mass_clock = MassClock.find_by_id(params[:id])
    if params[:selected_ids]
      notice = []
      time_in = Time.now
      users_added = []
      selected_users = User.get_selected(params)
      for user in selected_users
        user.clock ? user.clock.destroy : nil
        user.clock = Clock.find_or_create(user, @mass_clock.department)
        user.clock.department = @mass_clock.department
        user.clock.mass_clock = @mass_clock
        if user.clock.clock_in(time_in) and @mass_clock.save
          users_added << user.name
        else
          notice << "Error saving clock for #{item.payform.user.name}"
        end
      end
      notice << "Clocked in successfully for the following users: #{users_added.to_sentence}" unless users_added.empty?
      redirect_with_flash notice, :action => "index", :id => @mass_clock.department
    end
  end
  
  def edit_mass_clock
    @mass_clock = MassClock.find_by_id(params[:id])
    if params[:payform_item] and @mass_clock
      notice = []
      @mass_clock.description = params[:payform_item][:description]
      @mass_clock.category_id = params[:payform_item][:category_id]
      if @mass_clock.save
        for payform_item in @mass_clock.payform_items
          unless payform_item.payforms[0].printed
            payform_item.payforms[0].unapprove
            payform_item.description = @mass_clock.description
            payform_item.category_id = @mass_clock.category_id
            unless payform_item.save
              notice << "Error saving payform item for " + payform_item.payforms[0].user
            end
          else
            notice << "Payform already printed for " + payform_item.payforms[0].user
          end
        end
        notice << "Mass Clock Saved"
      else 
        notice << "Error saving mass clock"
      end
      
      redirect_with_flash notice, :action => "index", :id => @mass_clock.department
    elsif !@mass_clock
      redirect_with_flash "Invalid entry", :action => "index"
    end
  end
  

  
  def mass_clocks_action
    notices = []
    if params[:clock_out] and (clock = Clock.find_by_id(params[:clock_out]))
      notices << clock_out(clock)
    elsif params[:clock_all_out] and (mc = MassClock.find_by_id(params[:clock_all_out]))
      for clock in mc.clocks
        notices << clock_out(clock)
      end
    elsif params[:cancel_all] and (mc = MassClock.find_by_id(params[:cancel_all]))
      notice = "Clock cancelled for: "
      for clock in mc.clocks
        notice += clock.user.name + (clock == mc.clocks[-1] ? "." : ", ") if clock.destroy
      end
      notices << notice
    elsif params[:delete_clock] and (clock = Clock.find_by_id(params[:delete_clock]))
      notices << "Clock cancelled for " + clock.user.name if clock.destroy
    elsif params[:delete_item] and (payform_item = PayformItem.find_by_id(params[:delete_item]))
      n = "Payform Item deleted for " + (payform_item.payforms[0]).user.name 
      notices << n if payform_item.destroy
    elsif params[:delete_all] and (mc = MassClock.find_by_id(params[:delete_all]))
      notice = "Payform Item deleted for: "
      for payform_item in mc.payform_items
        n = (payform_item.payforms[0]).user.name + (payform_item == mc.payform_items[-1] ? "." : ", ") 
        notice += n if payform_item.destroy
      end
      notices << notice
    elsif params[:delete] and (mc = MassClock.find_by_id(params[:delete]))
      notice = "Clocks stopped for: "
      for clock in mc.clocks 
        notice += clock.user.name + (clock == mc.clocks[-1] ? "." : ", ") if clock.destroy 
      end
      notices << notice unless mc.clocks.empty?
      notice = "The following user payform items exist and have <strong>not</strong> been removed: "
      for payform_item in mc.payform_items
        payform_item.mass_clock = nil
        payform_item.save
        notice += payform_item.payforms[0].user.name + (payform_item == mc.payform_items[-1] ? "." : ", ")
      end
      notices << "Mass Clock deleted" if mc.destroy
      notices << notice unless mc.payform_items.empty?
    else
      notices << "Invalid Action"
    end
    redirect_with_flash notices, :action=> (params[:redirect] ? params[:redirect] : "index"), :id => get_dept_from_url and return
  end

  def controller_name
    PayformAdminController.controller_name
  end
  
  def set_navbar
    left_nav("payform_admin")
  end

  protected
  
  def clock_out(clock)
    if clock.seconds <= 38
      notice = clock.user.name + " was not clocked in for long enough. No time saved." if clock.destroy
    else
      mc = clock.mass_clock
      clock.clock_out
      week = default_week_unless_already nil
      year = default_year_unless_already nil
      payform_item = PayformItem.new(
        :hours       => clock.hours ,
        :date        => Date.today,
        :category_id    => mc.category,
        :description => "(#{clock.start.strftime('%I:%M%p')} to #{clock.out.strftime('%I:%M%p')}): #{mc.description}",
        :added_by    => "Mass Punch Clock",
        :department_id => mc.department_id) 
      payform = Payform.find_or_create(week, year, clock.user, mc.department)
      if !payform.printed? and payform.unapprove
        payform_item.payforms << payform
        payform_item.mass_clock = mc
        if payform_item.save
          clock.destroy
          notice = "Successfully clocked out " + clock.user.name
        else
          notice = "Error saving job"
        end
      else
        notice = clock.user.name + "'s current payform already printed"
      end
    end
    notice
  end

end
