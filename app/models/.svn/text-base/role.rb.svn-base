# See <a href="http://wiki.rubyonrails.com/rails/show/AccessControlListExample">http://wiki.rubyonrails.com/rails/show/AccessControlListExample</a>
# and <a href="http://wiki.rubyonrails.com/rails/show/LoginGeneratorAccessControlList">http://wiki.rubyonrails.com/rails/show/LoginGeneratorAccessControlList</a>

class Role < ActiveRecord::Base
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :users
  has_and_belongs_to_many :departments
  has_and_belongs_to_many :groups
  
  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  validate :must_belong_to_department
  
  before_validation :create_display_name_if_not_present
  # after_save :delete_users_permission_cache

  #overwrite the origianl all to have it ordered by 'name' ASC -H
  named_scope :all, :order => 'name'
  
  def must_belong_to_department
    errors.add("Role must belong to at least one department.", "") if self.departments.empty?
  end
    
  def self.default(name, department)
   new :name         => name + '/@' + department.name.decamelize, 
       :display_name => department.name,
       :description  => 'Grants ' + name + ' access for ' + department.name + '.'
  end
    
  # Return true/false if Role contains permission.
  def authorized?(resource)
    return permission_strings.include?(resource)
  end

  # Load permission strings 
  def permission_strings
    self.permissions.collect &:name
  end
  
  # The norm is that display name is the last part of name string (after the forward slash) -H
  # before_validation takes care of this
  def create_display_name_if_not_present
    self.display_name = name.split('/').last if self.display_name.nil? or self.display_name.empty?
  end
  
  def before_destroy
    #delete all permissions that only belong to this role -H
    self.permissions.each { |perm| perm.destroy if perm.roles.size==1 }
  end
  
  def delete_users_permission_cache
    users.each { |u| u.delete_permission_cache }
  end
  
end