require 'net/ldap'

# this model expects a certain database layout and it's based on the name/login pattern. 
class User < ActiveRecord::Base
  #Shift
  has_many :shifts
  has_many :subs
  has_one :preference
  #Payform:
  has_many :payforms
  has_one  :clock

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :departments
   
  validates_uniqueness_of :login, :on => :create
  validates_length_of :login, :within => 2..40
  validates_presence_of :login
  
  validate :must_belong_to_department
  
  # after_save :delete_permission_cache
  
  named_scope :all, :order => :name
  named_scope :active, :conditions => { :active => 1 }
  named_scope :inactive, :conditions => { :active => 0 }
    
  #only search active users
  def self.search(str = nil)
    if str
      active.find(:all, :conditions => ['(name LIKE ? OR login LIKE ?)', "%#{str}%", "%#{str}%"])
    else
      active.find(:all)
    end
  end
  
  def self.get_selected(params)
    find(params[:selected_ids].split(',')) rescue []
  end
    
  def must_belong_to_department
    errors.add("User must belong to at least one department.", "") if self.departments.empty?
  end

  def full_name
    first_name + ' ' + last_name
  end
  # Return true/false if User is authorized for resource.
  def authorized?(resource)
    return false unless self.active
    # return true if role_authorized?('superuser') 
    #OPTIMIZE: DO WE WANT THIS? It causes you to have access to all departments in all controllers, no matter what your permissions are.
  
    # return permission_strings.include?(resource) #reduced performance
    return permission_strings_cached.include?(resource) #causes caching bug
  end

  # Load permission strings 
  def permission_strings
    #take union with other roles that the user has
    # perm_str = groups.collect(&:permission_strings).flatten | roles.collect(&:permission_strings).flatten
    #the above code is short but slower
    perm_str = []
    groups.each { |g| perm_str |= g.permission_strings }
    roles.each {|r| perm_str |= r.permission_strings}
    # Append the "everyone" role to all users
    perm_str |= Role.find_by_name("everyone").permission_strings
    perm_str
  end

  def permission_strings_cached
    Rails.cache.fetch("user_permission_strings_#{id}") {permission_strings}
  end
  
  def delete_permission_cache
    Rails.cache.delete("user_permission_strings_#{id}")
  end
    
  # Return true/false if User contains role.
  def role_authorized?(resource)
    return role_strings.include?(resource)
  end

  # Load role strings 
  def role_strings
    roles.collect(&:name)
  end
  
  def authorized_departments
    Department.all.select {|d| authorized?(d.permission.name)}
  end
  
  def authorized_location_groups(department)
    department.location_groups.select {|lg| lg.allow_admin? self}
  end
  
  def group_roles
    a = []
    groups.each do |grp|
      a |= grp.roles
    end
    a
  end
  
  def import_from_ldap
    # Setup our LDAP connection
    ldap = Net::LDAP.new( :host => "directory.yale.edu", :port => 389 )
    # We filter results based on netid
    filter = Net::LDAP::Filter.eq( "uid", login)
    ldap.open do |ldap|
      # Search, limiting results to yale domain and people
      ldap.search( :base => "ou=People,o=yale.edu", :filter => filter, :attributes => ["givenname", "sn", "mail"], :return_result => false ) do |entry|
        self.first_name = "#{entry['givenname']}"
        self.last_name  = "#{entry['sn']}"
        self.email = "#{entry['mail']}"
      end
    end
    self.save
  rescue 
     errors.add_to_base "LDAP Error " + $! # Will trigger an error, LDAP is probably down
     false
  end
  
end
