class ShiftAdmin::AnnouncementsController < ShiftAdminController
  
  def index
    redirect_with_flash flash[:notice], :action => :manage, :id => get_dept_from_url.id
  end
  
  def manage
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :manage, :id => @department.id and return
    end
    @announcement = Announcement.new
  end
  
  def add
    if params[:announcement] and request.post?
      @announcement = Announcement.new(params[:announcement])
      @announcement.department = get_dept_from_url
      @announcement.author = @user
      @announcement.start_time = Time.now if params[:start_time_choice] == 'now'
      @announcement.end_time = nil if params[:end_time_choice] == 'indefinite'
      if @announcement.save
        flash = "Announcement Saved"
      else
        flash = "Error saving"
      end
      redirect_with_flash flash, :action => :manage, :id => @announcement.department and return 
    end
  end
  
  def edit
    @announcement = Announcement.find_by_id(params[:id])
    if @announcement 
      @department = @announcement.department
      if params[:announcement] and request.post?   
        @announcement.for_department = nil
        @announcement.location_groups = []
        @announcement.locations = []
        params[:announcement][:start_time] = Time.now if params[:start_time_choice] == 'now'
        params[:announcement][:end_time] = nil if params[:end_time_choice] == 'indefinite'
        if @announcement.update_attributes(params[:announcement])
          redirect_with_flash "Announcement Saved", :action => :manage, :id => @announcement.department and return 
        end
      end
    else
      redirect_with_flash "Invalid Announement", :action => :manage, :id => session["current_chooser_choice"][self.controller_name] and return
    end
  end
  
  def update_checkboxes
    @department = Department.find(session["current_chooser_choice"][self.controller_name])
    @announcement = Announcement.new(params[:announcement])
    render :update do |page|
      page.replace_html('checkboxes_div', :partial => "checkboxes")
    end
  end
  
  def delete
    announcement = Announcement.find_by_id params[:id]
    if announcement && request.post?
      if announcement.destroy
        redirect_with_flash "announcement Deleted", :action => :index
      end
    else
    redirect_with_flash "Invalid announcement", :action => :index
    end
  end
  
  def controller_name
    ShiftAdminController.controller_name
  end
  
  protected
  

  
end
