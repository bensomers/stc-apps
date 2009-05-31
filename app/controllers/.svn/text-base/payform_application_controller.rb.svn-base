require 'cas_acl'
class PayformApplicationController < ApplicationController  
  # Check authentication with CAS login
  before_filter CASACL::CASFilter
  before_filter :fetch_user_data
  before_filter :chooser
  
  def add_job
    @payform = Payform.find_by_id params[:id]
    @department = Department.find_by_id(@payform.department_id)
    @payform_item = PayformItem.new
    if @payform and @payform.authorized?(@user, controller_name)
      @days = @payform.get_dates if params[:id]
      
      if params[:payform_item] and request.post?
        @payform_item = PayformItem.new(params[:payform_item])
        @payform_item.hours = get_payform_item_hours #calculate from params[:calculate_hours]
        @payform_item.date = Date.parse(params[:date])
        @payform_item.payforms << @payform
        @payform_item.added_by = @user.login
        @payform_item.department = @department
        if @payform_item.save
          flash = 'Job created.'
          unless controller_name == 'payform_admin'
            if @payform.submitted?
              @payform.unsubmit
              flash += '<br/><strong>Warning:</strong> Your payform has been unsubmitted.'
            end
          else
            @payform.unapprove
            flash += '<br/><strong>Warning:</strong> Payform has been unapproved.'
          end
          
          respond_to do |format|
            format.html do
              redirect_with_flash flash, :action => :view, :id => @payform.id
            end
            format.js do
              render :update do |page|
                page["add_job_div"].visual_effect :slide_up, :duration => 0.8
                page.replace_html "payform_status", :partial => 'payform/payform_status', :object => @payform
                page.replace_html "payform", :partial => 'payform/payform', :object => @payform
                page.replace_html "buttons", :partial => 'payform/payform_button', :object => @payform
                page[@payform_item.div_id].visual_effect :highlight, :duration => 1, :startcolor => "#104E8B"
              end
            end
          end
          return
        end
      end
      respond_to do |format|
        format.html do
          render :template => 'payform/add_job'
        end
        format.js do
          render :update do |page|
            div_id = 'add_job_div'
            page["messages"].visual_effect :blind_up, :duration => 0.8
            page[div_id].hide
            page.replace_html div_id, :partial => "payform/quick_add_job", :object => @payform_item
            page[div_id].visual_effect :slide_down, :duration => 0.5
            page.replace_html 'add_job_link_div', "Add Job"
          end
        end
      end
      
    else
      redirect_with_flash 'Invalid Payform', :action => :index
    end
  end
  
  #TODO: problem undefined variable or local method clock in _job_fields
  #so this method doesn't run
  #only when first start the server
  def edit_job
    @payform_item = PayformItem.find_by_id params[:id] if params[:id]
    if params[:payform_id] and @payform_item and @payform_item.mass
      @payform = Payform.find_by_id params[:payform_id]
    elsif @payform_item
      @payform = @payform_item.payforms[0]
    end
    if @payform_item and @payform.authorized?(@user, controller_name)
      @days = @payform.get_dates  
      if params[:payform_item] 
        @user = get_user
        
        @edit_item = EditItem.new(params[:payform_item])
        @edit_item.date = Date.parse(params[:date])
        @new_range = '!!!'
        @edit_item.hours = get_payform_item_hours(@new_range)
        
        #update new our range info
        @edit_item.description.gsub! /^\(\d\d:\d\d(AM|PM|am|pm)\s*(to)\s*\d\d\:\d\d(AM|PM|am|pm)*\)/,@new_range
        
        hours = @payform_item.hours
        date = @payform_item.date
        description = @payform_item.description
        category_id = @payform_item.category_id
        
        @payform_item.hours = @edit_item.hours
        @payform_item.date = @edit_item.date
        @payform_item.description = @edit_item.description
        @payform_item.category_id = @edit_item.category_id
        @payform_item.edit_items << @edit_item
        
        if @payform_item.save
          @edit_item.hours = hours
          @edit_item.date = date
          @edit_item.description = description
          @edit_item.category_id = category_id
          @edit_item.edited_by = @user.login
          if @edit_item.save
            
            
            if @payform_item.mass
              flash = "Job saved"
              # email users.  can only be done by admin
              @payform_item.payforms.each do |payform|
                @payform2 = payform
                email = PayformMailer.create_admin_edit(@payform2, @payform_item, @edit_item)

                PayformMailer.deliver(email)
                if @payform2.approved?
                  @payform2.unapprove
                end
              end
            else
              # if admin edit, e-mail to warn user that their payform had been edited
              if controller_name == "payform_admin"
                email = PayformMailer.create_admin_edit(@payform, @payform_item, @edit_item)

                PayformMailer.deliver(email)
                flash = "Job saved" + "<pre>" + email.encoded + "</pre>"
                if @payform.approved?
                  @payform.unapprove
                  flash += "<br/><strong>Warning:</strong> Payform has been unapproved."
                end
              elsif @payform.submitted?
                if @payform.unsubmit
                  flash = "Job saved. <br/><strong>Warning:</strong> Your payform has been unsubmitted."
                end
              end
            end
          redirect_with_flash flash, :action => :view, :id => @payform.id and return
        else
          
          flash = "Fatal error saving job"
        end
      
      else
        #THIS WILL TAKE THE ERRORS FROM edit_item AND ADD THEM TO payform_item:
        #----------------------------------------------------------------------
        errors = ActiveRecord::Errors.new(nil)
        @payform_item.errors.each { |k,m| errors.add(k,m) unless k == "edit_items" }
        @edit_item.errors.each { |k,m| errors.add(k,m) }
        @payform_item.errors.clear
        errors.each { |k,m| @payform_item.errors.add(k, m) }
        #----------------------------------------------------------------------
      end
    else
      @edit_item = EditItem.new(
                                :hours        => @payform_item.hours,
                                :date         => @payform_item.date,
                                :description  => @payform_item.description,
                                :category_id  => @payform_item.category_id,
                                :edited_by    => @user.login)
    end
    else
      redirect_with_flash "Invalid Payform", :action => :index
    end
  end
  
  def flatten_mass_job
    @payform_item = PayformItem.find_by_id params[:id] if params[:id]
    @payform = Payform.find_by_id params[:payform_id] if params[:payform_id]
    if @payform_item and @payform.authorized?(@user, controller_name)
      @days = @payform.get_dates  
      if params[:payform_item] 
        @user = get_user
        
        @new_payform_item = PayformItem.new(params[:payform_item])
        
        hours = @payform_item.hours
        date = @payform_item.date
        description = @payform_item.description
        category_id = @payform_item.category_id
        reason = @new_payform_item.reason
        
        @new_payform_item.reason = nil
        @new_payform_item.date = Date.parse(params[:date])
        @new_payform_item.hours += params[:other][:minutes].to_i / 60.0
        @new_payform_item.added_by = @payform_item.added_by
        @new_payform_item.department = @payform.department
        @new_payform_item.payforms << @payform
        @payform_item.flattened_jobs << @new_payform_item
        @new_payform_item.save!
        
        @payform_item.edit_items.each do |edit_item|
          @new_edit_item = EditItem.new(
                                        :hours => edit_item.hours,
                                        :date => edit_item.date,
                                        :description => edit_item.description,
                                        :reason => edit_item.reason,
                                        :category_id => edit_item.category_id,
                                        :edited_by => edit_item.edited_by
          )
          @new_payform_item.edit_items << @new_edit_item
          unless @new_edit_item.save
            redirect_with_flash "Error Updating Edits", :action => :view, :id => @payform.id and return
          end
        end
        
        @edit_item = EditItem.new
        @edit_item.hours = hours
        @edit_item.date = date
        @edit_item.description = description
        @edit_item.reason = reason
        @edit_item.category_id = category_id
        @edit_item.edited_by = @user.login
        
        @new_payform_item.edit_items << @edit_item
        
        if @new_payform_item.save
          @payform_item.payforms.delete(@payform)
          if @payform_item.save
            # if admin edit, e-mail to warn user that their payform had been edited
            if controller_name == "payform_admin"
              email = PayformMailer.create_admin_edit(@payform, @new_payform_item, @edit_item)

              PayformMailer.deliver(email)
              flash = "Job saved" + "<pre>" + email.encoded + "</pre>"
              if @payform.approved?
                @payform.unapprove
                flash += "<br/><strong>Warning:</strong> Payform has been unapproved."
              end
            elsif @payform.submitted?
              if @payform.unsubmit
                flash = "Job saved. <br/><strong>Warning:</strong> Your payform has been unsubmitted."
              end
            end
          else
            flash = "Job Flattened, but Error Removing User From Mass Job"
          end
          redirect_with_flash flash, :action => :view, :id => @payform.id and return
        else
          #THIS WILL TAKE THE ERRORS FROM edit_item and new_payform_item AND ADD THEM TO payform_item:
          #does not include errors from transferring old edit items
          #----------------------------------------------------------------------
          errors = ActiveRecord::Errors.new(nil)
          #@payform_item.errors.each { |k,m| errors.add(k,m) unless k == "edit_items" }
          #@new_payform_item.errors.each { |k,m| errors.add(k,m) unless k == "edit_items" }
          @edit_item.errors.each { |k,m| errors.add(k,m) }
          @payform_item.errors.clear
          errors.each { |k,m| @payform_item.errors.add(k, m) }
          #----------------------------------------------------------------------
        end
      else
        @edit_item = EditItem.new(
                                  :hours        => @payform_item.hours,
                                  :date         => @payform_item.date,
                                  :description  => @payform_item.description,
                                  :category_id  => @payform_item.category_id,
                                  :edited_by    => @user.login)
      end
    else
      redirect_with_flash "Invalid Payform", :action => :index
    end
  end
  
  def delete_job
    @payform_item = PayformItem.find_by_id params[:id] if params[:id]
    if params[:payform_id] and @payform_item and @payform_item.mass
      @payform = Payform.find_by_id params[:payform_id] 
    elsif @payform_item
      @payform = @payform_item.payforms[0]
    end
    if @payform_item and @payform.authorized?(@user, controller_name)
      if params[:payform_item] and request.post?
        @payform_item.reason = params[:payform_item][:reason]
        @payform_item.active = false
        
        if @payform_item.mass
          @payform_item.payforms.each do |payform|
            payform.unsubmit
          end
        else
          @payform.unsubmit 
        end
        
        if @payform_item.save
          redirect_with_flash "Payform item deleted", :action => :view, :id => @payform.id
        end
      end
    else
      redirect_with_flash "Invalid Payform", :action => :index
    end
  end
  
  def disavow_mass_job
    @payform_item = PayformItem.find_by_id params[:id] if params[:id]
    @payform = Payform.find_by_id params[:payform_id] if params[:payform_id]
    if @payform_item and @payform.authorized?(@user, controller_name)
      if request.post?
        @payform_item.payforms.delete(@payform)
        if @payform_item.save
          redirect_with_flash "Job deleted", :action => :view, :id => @payform.id
        else
          redirect_with_flash "Job Failed To Save", :action => :view, :id => @payform.id
        end
      end
    else
      redirect_with_flash "Invalid Payform", :action => :index
    end
  end
  
  def choose_week
    #incoming from change_week partial
    id = params[:id] if params[:id]
    if params[:payform]
      date = Date.parse(params[:payform][:week])
      flash[:notice] = "Changed payform to pay week: " + date.to_s
    end
    if params[:redirect] and params[:redirect] != "view"
      redirect_param = params[:redirect]
    else
      redirect_param = "index"
    end
    redirect_to :action => redirect_param, :id => id, :payform => params[:payform]
  end
  
  #-------------------------------------------------------
  # Methods to convert user inputted times to hours
  #-------------------------------------------------------
  def get_payform_item_hours(new_range='')
    if params[:calculate_hours] == "user_input"
      return (params[:payform_item][:hours].to_i) + (params[:other][:minutes].to_i / 60.0)
    elsif params[:calculate_hours] == "time_input"
      start_params = []
      stop_params = []
      for num in (1..6)
        start_params << params[:time_input]["start(#{num}i)"].to_i
        stop_params << params[:time_input]["end(#{num}i)"].to_i
      end
      start_time = convert_to_time(start_params)
      stop_time = convert_to_time(stop_params)      
      @new_range = "(#{start_time.to_s(:am_pm)} to #{stop_time.to_s(:am_pm)})" if @new_range
      if @payform_item
        #append time to description
        @payform_item.description = "(#{start_time.strftime('%I:%M%p')} to #{stop_time.strftime('%I:%M%p')}) #{@payform_item.description}"
      end
      return (stop_time - start_time) / 3600.0  #convert seconds to hours
    else
      return 0
    end
  end
  
  def convert_to_time(date_array)
    # 0 = year, 1 = month, 2 = day, 3 = hour, 4 = minute, 5 = meridiem
    if date_array[3] == 12
      date_array[3] -= 12
    end
    if date_array[5] == 1
      date_array[3] += 12
    end
    Time.utc(date_array[0], nil, nil, date_array[3], date_array[4])
  end
  
  #-------------------------------------------------------
  # Shared Helper Methods
  #-------------------------------------------------------
  protected
  def default_week_unless_already(week)
    week || Date.tomorrow.cweek
  end
  
  def default_year_unless_already(year)
    year || Date.tomorrow.at_beginning_of_week.year
  end
  
  def get_previous_weeks
    @dates = []
    #TODO: How many previous payforms should this show?
    26.times {|n| @dates << Date.tomorrow.at_end_of_week-(1+n*7) }
    @dates
  end
  
  
  
  def chooser_options
    { "choices" => get_departments,
        "required" => true }
  end
  
  #-------------------------------------------------------
  # Private Helper Methods
  #-------------------------------------------------------
  private
  
  def fetch_user_data
    @user = get_user
  end
end
