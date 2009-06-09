class StickyController < ShiftController

before_filter :fetch_report_or_redirect, :except => [:create, :view, :admin_submit, :mark_as_payform_added, :view_float]

  def controller_name
    ShiftController.controller_name
  end

  def index
    @location_groups = fetch_location_groups
    objects = []
    objects << @user
    @location_groups.each do |location_group|
      objects = objects + location_group.locations
      objects << location_group
    end
    objects << @department

    @stickies = Sticky.fetch_authorized_active(objects)
  end

  def show
  end

  def add
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
        redirect_with_flash("Sticky created", {:controller => 'report'}) if @sticky.save
      end
    end
  end

  def edit
    fetch_stickies

  end

  def create
  end

  def update
  end

  def remove
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

private

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

  def fetch_report_or_redirect
    @user = get_user
    @shift_report = ShiftReport.find_current_report(@user)
    unless @shift_report
      redirect_with_flash("You are not signed into a shift.",
        :controller => "shift", :action => "index")
    end
  end

end

