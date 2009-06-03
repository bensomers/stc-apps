# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :delete_user_permission_cache
  before_filter :set_user_exists
  include HoptoadNotifier::Catcher
  helper_method :get_department
  helper_method :get_user

  protected
  # Returns a valid user model based on whether the user exists in the database
  def get_user
    session[:user_exists] ? User.find_by_login(session[:casfilteruser]) : User.new(:login => session[:casfilteruser])
  end

  def delete_user_permission_cache
    get_user.delete_permission_cache
  end

  def set_user_exists
    session[:user_exists] = true if User.find_by_login(session[:casfilteruser])
  end

  #get department choice off the session
  def get_department
    # y session["current_chooser_choice"]
    Department.find session["current_chooser_choice"][controller_name]
  end

  #use this if you are either going to pass the department as a parameter, or default to the chooser department
  #this is useful for pages where you would like the url to possibly specify the department (for bookmarking purposes)
  #make sure to specify how it gets the proper permission for that department
  def get_dept_from_url
    #try to get department id form url first,  then from session cache
    #Nathan, I'm changing the code back because it also takes care of invalid id,
    #the other one you changed to throws up error if you give invalid id, which is unnecessary
    department = Department.find_by_id(params[:id]) || get_department

    #the following occurs if department's not been set in session and no dept id is passed in url
    department = get_departments[0] if department.nil? or !get_user.authorized?(get_permission(department))

    #update session
    session["current_chooser_choice"][controller_name] = department.id
    department
  end

  #specify where to find the permission required for viewing that department in shifts or payform
  def get_permission(department)
    perm_name = 'not_accessible0921834021938420934'
    if controller_name == 'payform' or controller_name == 'payform_admin'
      config = department.payform_configuration
      if config
        perm_name = (controller_name == 'payform') ? config.payform_permission.name : config.payform_admin_permission.name
      end
    elsif controller_name == 'shift' or controller_name == 'shift_admin'
      config = department.shift_configuration
      if config
        perm_name = (controller_name == 'shift') ? config.shift_permission.name : config.shift_admin_permission.name
      end
    end
    perm_name
  end

  #will return all departments that are authorized for a given permission
  def get_departments
    @user ||= get_user
    Department.all.select {|d| @user.authorized?(get_permission(d))}
  end

  #return an array giving the date of days in the week, index 0 points to Sunday, 6 to Monday
  def get_week(date = Date.today) #call with no parameter for the current week
    ns = date - date.wday         #get the date of Sunday before the "date"
    #return a list of date for each day of the week, starting sunday
    [ns, ns + 1, ns + 2, ns + 3, ns + 4, ns + 5, ns + 6]
  end

  def chooser_options
    { "choices" => [],
      "required" => false }
  end

  def redirect_with_flash(msg = nil, options = {:action => :index})
    if msg
      msg = msg.join("<br/>") if msg.is_a?(Array)
      flash[:notice] = msg
    end
    redirect_to options
  end

  def chooser
    session["current_chooser_choice"] ||= {}
    depts = chooser_options["choices"]
    authorized_dept_ids = depts.collect { |d| d.id }
    @chooser_list = depts.collect{|c| [c.name, c.id]}

    #to keep department choice consistent across controller, HOWEVER user must have permission to access it
    if (a = session["current_chooser_choice"]["all"]) and authorized_dept_ids.include?(a.to_i)
      session["current_chooser_choice"][controller_name] = a
    end

    if @chooser_list.empty? and chooser_options["required"] and session[:user]
      flash.now[:notice] = "You do not have access to any departments under #{controller_name.capitalize}."
      render :template => "index/access_denied"
    end

    url_has_dept = false

    #chooser form uses a GET request:
    if params[:dept]
      dept_id = params[:dept].to_i
      if authorized_dept_ids.include?(dept_id)
        session["current_chooser_choice"][controller_name] = dept_id
        url_has_dept = true
      else
        flash.now[:notice] = "Invalid department id #{params[:dept].h} or you do not have access to that department."
        render :template => "index/access_denied"
      end
      params[:dept] = nil
    end

    unless (session["current_chooser_choice"][controller_name] or @chooser_list.empty?)
      session["current_chooser_choice"][controller_name] = @chooser_list.first[1]
    end

    session["current_chooser_choice"]["all"] = session["current_chooser_choice"][controller_name]

    # uncomment this if you wanna hide the dept= in the url.  it's unnecessary anyways
    # redirect_to url_for({}) if url_has_dept
  end

  def left_nav(layout_name)
    @left_nav = 'layouts/include/' + layout_name + '.html.erb'
  end

end
