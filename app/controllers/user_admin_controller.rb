

class UserAdminController < ApplicationController
  helper_method :superuser_access?
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :chooser
  before_filter :set_navbar
  auto_complete_for :group, :name
  # after_filter :delete_user_permission_cache, :only => [:edit_user, :edit_department, :edit_group, :edit_role, :edit_permission, :destroy_permission, :destroy_role,
  # :destroy_department, :destroy_group, :destroy_user]

  def department_placeholder_all
    a = Department.new(:name => 'All')
    a.id = 0
    a
  end

  def chooser_options
    department_list = []
    department_list += get_user.authorized_departments
    department_list << department_placeholder_all if superuser_access?
    return { "choices" => department_list, "required" => true }
  end

  def get_department
    dept_id = session["current_chooser_choice"][controller_name]
    if dept_id.to_s == '0'
      return department_placeholder_all
    else
      # print dept_id
      Department.find(dept_id)
    end
  end

  def index
    @user = get_user
  end

  def superuser_access?
    get_user.authorized?("user_admin/superuser")
  end

  def filter_by_department(full_list, params={})
    dept = get_department
    authorized_list = []
    full_list.each {|item| authorized_list << item if (get_department.name == "All" or item.departments.include?(dept)) ^ params[:invert] }
    authorized_list
  end

  def manage_users
    @users = filter_by_department(User.active.sort_by{|u|u.name})
    @active = true
    if params[:id] == "inactive"
      @users = filter_by_department(User.inactive.sort_by{|u|u.name})
      @active = false
    end
  end

  def manage_roles
    @roles = filter_by_department(Role.find(:all, :order => "name"))
  end

  def manage_permissions
    @permissions = Permission.find(:all, :order => "name")
  end

  def manage_departments
    @departments = Department.find(:all, :order => "name")
  end

  def manage_groups
    @groups = filter_by_department(Group.find(:all, :order => "name"))
  end


  def edit_permission
    if params[:id]
      @permission = Permission.find(params[:id])
    else
      @permission = Permission.new
    end

    if request.post? and params[:permission]
      if @permission.update_attributes(params[:permission])
        redirect_with_flash 'Permission was successfully updated.', :action => 'manage_permissions'
      else
        render :action => 'edit_permission'
      end
    end
  end


  def destroy_permission
    Permission.find(params[:id]).destroy
    redirect_to :action => 'manage_permissions'
  end

  def edit_role
    if params[:id]
      @role = Role.find(params[:id])
    else
      @role = Role.new
    end
    @permissions = Permission.find(:all, :order => 'name')

    if request.post? and params[:role]
      params[:role][:permission_ids] ||= []
      params[:role][:department_ids] ||= []

      begin
        #update_attributes is wrapped in a transaction to ensure that associations are not saved if validation fails on permission
        Role.transaction do
          @role.update_attributes!(params[:role])
        end
        redirect_with_flash 'Role was successfully updated.', :action => 'manage_roles'
      rescue
        render :action => 'edit_role'
      end
    end
  end

  def destroy_role
    Role.find(params[:id]).destroy
    redirect_to :action => 'manage_roles'
  end

  def edit_department
    @department = params[:id] ? Department.find(params[:id]) : Department.new
    @permissions = Permission.find(:all, :order => 'name')
    if request.post? and params[:department]
      Department.transaction do
        @department.rename_roles_and_permissions_and_groups(params[:department][:name]) if @department.permission
        @department.update_attributes!(params[:department])
        unless @department.permission
          @department.permission = find_and_create_roles_and_permissions('user_admin', @department)
          @department.save!
        end
      end
      create_configuration(@department, ShiftConfiguration)
      create_configuration(@department, PayformConfiguration)
      redirect_with_flash 'Department was successfully updated.', :action => 'manage_departments'
    end
  end

  def destroy_department
    Department.find(params[:id]).destroy
    redirect_to :action => 'manage_departments'
  end


  def edit_group
    @group = params[:id] ? Group.find(params[:id]) : Group.new
    if get_department.id == 0
      @roles = Role.all
    else
      @roles = Role.find(:all, :order => 'name').select{|r| r.departments.include?(get_department)}
    end
    if request.post? and params[:group]
      params[:group][:role_ids] ||= []
      params[:group][:department_ids] ||= []
      begin
        #update_attributes is wrapped in a transaction to ensure that associations are not saved if validation fails on group
        Group.transaction do
          @group.update_attributes!(params[:group])
        end
        redirect_with_flash 'Group was successfully updated.', :action => 'manage_groups'
      rescue
        render :action => 'edit_group'
      end
    end
  end

  def destroy_group
    Group.find(params[:id]).destroy
    redirect_to :action => 'manage_groups'
  end

  def edit_user
    if params[:id]
      @user = User.find(params[:id])
    else
      if not superuser_access? and params[:user] and params[:user][:login] and (existing_user = User.find_by_login(params[:user][:login]))
        @user = existing_user
        @user.active = true
      else
        @user = User.new
      end

      @user.departments << get_department if not superuser_access?
    end

    @departments = Department.find(:all, :order => 'name')
    @groups = filter_by_department(Group.find(:all, :order => "name"))
    @roles = filter_by_department(Role.find(:all, :order => "name"))


    if request.post? and params[:user]
      params[:user][:group_ids] ||= []
      params[:user][:role_ids] ||= []
      params[:user][:department_ids] ||= [] if superuser_access?

      params[:user][:role_ids] += filter_by_department(@user.roles, :invert => true).map {|role| "#{role.id}"}
      params[:user][:group_ids] += filter_by_department(@user.groups, :invert => true).map {|group| "#{group.id}"}

      begin
        #update_attributes is wrapped in a transaction to ensure that associations are not saved if validation fails on user
        User.transaction do
          @user.update_attributes!(params[:user])
        end
      rescue
        render :action => "edit_user"
      else
        redirect_with_flash 'User was successfully updated.', :action => 'manage_users'
      end
    end
  end

  def edit_user_update_checkboxes
    @user = User.new
    @user.attributes = params[:user]

    @groups = filter_by_department Group.all
    @roles = filter_by_department Role.all
    render :update do |page|
      page.replace_html('department_div', :partial => "department_selector", :object => @user) if superuser_access?
      page.replace_html 'group_div', :partial => 'group_checkbox', :collection => @groups
      page.replace_html 'role_div', :partial => 'role_checkbox', :collection => @roles
    end
  end

  #Changes the active status of users
  def change_active_users
    if request.post?
      begin
        if params[:deactivated_users]
          params[:deactivated_users].each do |inactive|
            User.find_by_id(inactive).update_attributes({:active => false})
          end
          redirect_with_flash("Users deactivated", :action => "manage_users")
        elsif params[:activated_users]
          params[:activated_users].each do |active|
            User.find_by_id(active).update_attributes({:active => true})
          end
          redirect_with_flash("Users activated", :action => "manage_users")
        end
      rescue
        redirect_with_flash("Users could not all be changed", :action => "manage_users")
      end
    end

  end

  # Deletes the specified user and all role-user bindings
  def destroy_user
    if request.post?
      User.find(params[:id]).destroy
      redirect_to :action => 'manage_users'
    end
  end

  # Adds the comma delimited set of users with the specified roles
  def mass_add
    render :text => 'under construction'
  end

  # Deletes the set of users with the given privileges
  def empty_role
    if params[:id] and request.delete?
      RolesUser.delete_all ['role_id = ?', params[:id]]
      flash[:notice] = "The group has been emptied."
    end
    redirect_to :action => ''
  end

  def import_users
    @department ||= get_department
    if @department.name == 'All'
      redirect_with_flash('Admin must be in a department', :action => :index) and return
    end
    @failure = []
    @success = []
    wipe_group = params[:wipe]
    if request.post?
      user_str_list = params[:import].split ';'
      user_str_list.each do |user_str|
        name, netid, ein, *group_names = user_str.split ','
        unless name.blank? or netid.blank?
          user = User.find_or_create_by_login netid.squish
          user.name = name.squish
          user.ein = ein.squish.to_i unless (ein.nil? or ein.empty?)
          groups = group_names.map { |n| Group.find_by_name(n.squish) }
          groups.delete_if{|n| n.blank?}
          if wipe_group
            user.groups = groups
          else
            user.groups |= groups
          end

          user.departments << @department unless user.departments.include? @department
          if user.import_from_ldap# and user.save
            @success << user
            if user.groups.blank?
              user.errors.add_to_base('No group was added for this user')
              @failure << user
            end
          else
            @failure << user
          end
        end
      end
    end
  end

  def export_users
    @department ||= get_department
    if @department.id.zero?
      redirect_with_flash('Admin must be in a department', :action => :index) and return
    end
    # users = @department.users.all #use .all because it would sort by name (see user.rb)
    @result = []
    if request.post?
      selected_users = User.get_selected(params)
      @result = selected_users.map{|u| [u.name, u.login, u.ein, u.groups.collect(&:name)].join(', ') }.join(";\n")
    end
  end

  private

  def find_and_create_roles_and_permissions(name, department)
    controller_role = Role.find_by_name(name)
    perm = Permission.default(name, department)
    role = Role.default(name, department)

    controller_role.departments << department
    role.departments << department
    role.permissions << perm

    controller_role.save!
    role.save!
    perm.save!
    return perm
  end

  def extra_shift_permissions(dept,config)
    config.department_admin_permission = Permission.shifts_department_admin_permission(dept)
    role = Role.new :name         => config.department_admin_permission.name,
                    :display_name => "Department admin",
                    :description  => 'Grants shift department admin access for ' + dept.name + '.'
    role.departments << dept
    role.permissions << config.department_admin_permission
    role.save!
    config
  end

  def create_configuration(dept, model)
    unless model.find_by_department_id(dept.id)
      config = model.default
      config.department = dept
      config.permission = find_and_create_roles_and_permissions(model.permission_name, dept)
      config.admin_permission = find_and_create_roles_and_permissions(model.admin_permission_name, dept)
      config = extra_shift_permissions(dept,config) if model.permission_name == 'shift'
      config.save!
    end
  end

  def set_navbar
    left_nav("user_admin")
  end
end
