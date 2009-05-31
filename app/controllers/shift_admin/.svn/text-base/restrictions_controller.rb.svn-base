class ShiftAdmin::RestrictionsController < ShiftAdminController
  
  def index
    redirect_with_flash flash[:notice], :action => :manage, :id => @department.id
  end
  
  def manage
    @department = get_dept_from_url
    # if !params[:id] or params[:id].to_i != @department.id
    #   redirect_to(:action => :manage) and return
    # end
    if params[:restriction] && request.post?
      @restriction = Restriction.new(params[:restriction])
      @restriction.department = @department
      @restriction.max_subs = nil unless @restriction.max_subs > 0
      @restriction.starts = Time.now if params[:starts_choice] == 'now'
      @restriction.expires = nil if params[:expires_choice] == 'indefinite'
      @restriction.hours_limit += params[:minutes][:limit].to_i / 60.0
      @restriction.hours_limit = nil unless @restriction.hours_limit > 0
      if @restriction.save
        flash[:notice] = "Restriction Saved"
      end
    else
      @restriction = Restriction.new(:department_id => @department.id)
    end
  end
  
  def edit
    @restriction = Restriction.find_by_id(params[:id])
    if @restriction
      if params[:restriction] && request.post?
        @restriction.for_department = nil
        @restriction.location_groups = []
        @restriction.locations = []
        params[:restriction][:max_subs] = nil unless params[:restriction][:max_subs].to_i > 0
        params[:restriction][:starts] = Time.now if params[:starts_choice] == 'now'
        params[:restriction][:expires] = nil if params[:expires_choice] == 'indefinite'
        params[:restriction][:hours_limit] = params[:restriction][:hours_limit].to_i + params[:minutes][:limit].to_i / 60.0
        params[:restriction][:hours_limit] = nil unless params[:restriction][:hours_limit] > 0
        if @restriction.update_attributes(params[:restriction])
          redirect_with_flash("Restriction Saved", :action => :manage) and return 
        end
      end
    else
      redirect_with_flash("Invalid Restriction", :action => :manage) and return
    end
  end
  
  def update_checkboxes
    @department = Department.find(session["current_chooser_choice"][self.controller_name])
    @restriction = Restriction.new(params[:restriction])
    render :update do |page|
      page.replace_html('checkboxes_div', :partial => "checkboxes")
    end
  end
  
  def delete
    restriction = Restriction.find_by_id params[:id]
    if restriction && request.post?
      if restriction.destroy
        redirect_with_flash "Restriction Deleted", :action => :index
      end
    else
    redirect_with_flash "Invalid Restriction", :action => :index
    end
  end
  
  def controller_name
    ShiftAdminController.controller_name
  end
  
  protected
  

  
end
