class LocationGroup < ActiveRecord::Base
  has_many :locations
  # has_many :restrictions
  has_and_belongs_to_many :restrictions
  has_and_belongs_to_many :announcements
  
  belongs_to :department
  
  belongs_to :permission_view,
              :class_name => "Permission",
              :foreign_key => "perm_view_id"              
  belongs_to :permission_signup,
              :class_name => "Permission",
              :foreign_key => "perm_signup_id"              
  belongs_to :permission_admin,
              :class_name => "Permission",
              :foreign_key => "perm_admin_id"
  
  alias_attribute :name, :short_name
  
  validates_uniqueness_of :long_name, :short_name  
  validates_presence_of :long_name, :short_name, :department_id, :perm_view_id, :perm_signup_id, :perm_admin_id
#  validates_numericality_of :max_shift_length
  validate :min_length_less_than_max_length

  #callbacks to handle permission create, update, and delete
  before_validation :create_or_update_roles_and_permissions
  before_destroy :delete_roles_and_permissions
  # after_save :delete_users_permission_cache
  
  #not used.  only for debugging
  def permission_strings
    [permission_view.name, permission_signup.name, permission_admin.name]
  end

  def priority_list
    #this is to make sure we run the find only once for each object
    unless @list
      @list = Location.find :all, :conditions => ['location_group_id = ?', self.id], :order => 'priority DESC'
      #three dots:
      for i in 1...@list.size        
        if @list[i].priority == @list[i-1].priority
          @list[i].prior = @list[i-1].prior #if same priority, go up higher
        else
          @list[i].prior = @list[i-1]
        end
      end
      @list[0].prior = nil
    end
    @list
  end
  
  def allow_view?(user)
    user.authorized? permission_view.name
  end

  def allow_sign_up?(user)
    user.authorized? permission_signup.name
  end
  
  def allow_admin?(user)
    user.authorized? permission_admin.name
  end
  
  def start
    @start ||= self.department.shift_configuration.start.minutes
  end
    
  def end
    @end ||= self.department.shift_configuration.end.minutes
  end

  def create_or_update_roles_and_permissions
    if department and !short_name.blank? and !long_name.blank? #otherwise it's taken care of by validate_presence_of
      view = [department.shift_configuration.shift_permission.name, short_name.gsub(' ', '_').downcase] * '/'
      sign_up = [view, 'sign_up'] * '/'
      admin = [department.shift_configuration.shift_admin_permission.name, short_name.gsub(' ', '_').downcase] * '/'
      
      self.permission_view ||= Permission.new #if permission not created yet
      #if name should be created or changed
      if permission_view.name != view
        self.permission_view.update_attributes!(:name => view,:info => 'Grant Shift View Access for ' + short_name) #update permission name

        view_role = self.permission_view.roles.first #create role if necessary, there's only one role for this permission
        #create role if not exist
        view_role ||= Role.new do |r|
          r.departments << department
          r.permissions << permission_view
        end
        
        #update role name
        view_role.update_attributes!(:name => view, :display_name => short_name, :description => 'Grant Shift View Access for ' + short_name)
      end
      
      
      self.permission_signup ||= Permission.new #if permission not created yet
      if permission_signup.name != sign_up
        self.permission_signup.update_attributes!(:name => sign_up,:info => 'Grant Shift Sign up Access for ' + short_name) #update permission name
                
        signup_role = self.permission_signup.roles.first #create role if necessary, there's only one role for this permission
        #create role if not exist
        signup_role ||= Role.new do |r|
          r.departments << department
          r.permissions << permission_signup
        end
        
        #update role name
        signup_role.update_attributes!(:name => sign_up, :display_name => "Signup",:description => 'Grant Shift Sign up Access for ' + short_name)
      end

      self.permission_admin ||= Permission.new #if permission not created yet      
      if permission_admin.name != admin
        self.permission_admin.update_attributes!(:name => admin,:info => 'Grant Shift Admin Access for ' + short_name) #update permission name
                
        admin_role = self.permission_admin.roles.first #create role if necessary, there's only one role for this permission
        #create role if not exist
        admin_role ||= Role.new do |r|
          r.departments << department
          r.permissions << permission_admin
        end
        
        #update role name
        admin_role.update_attributes!(:name => admin, :display_name => short_name,:description => 'Grant Shift Admin Access for ' + short_name)
      end
      
      #this is needed probably because the id was not auto save for this belongs_to relationship. it just won't work without these lines
      self.perm_view_id = permission_view.id
      self.perm_admin_id = permission_admin.id
      self.perm_signup_id = permission_signup.id      
      #note we use these above 3 lines instead of calling self.save 
      #because save wont work: we're in before_validation which is called within the save method
    end
  end
  
  def delete_roles_and_permissions
    permission_view.roles.delete_all
    permission_admin.roles.delete_all
    permission_signup.roles.delete_all

    permission_view.destroy
    permission_admin.destroy
    permission_signup.destroy
    save!
  end
  
  def min_length_less_than_max_length
    errors.add_to_base("Invalid! Min shift length greater than max shift length!") if max_shift_length and min_shift_length and min_shift_length > max_shift_length
  end
  
  def delete_users_permission_cache
    users = [permission_view, permission_signup, permission_admin].collect(&:roles).flatten.uniq.collect(&:users).flatten.uniq
    users.each { |u| u.delete_permission_cache }
  end
  
  def  display_links
    return self.useful_links.to_s.split(",")
  end
  
end
