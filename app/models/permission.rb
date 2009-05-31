# See <a href="http://wiki.rubyonrails.com/rails/show/AccessControlListExample">http://wiki.rubyonrails.com/rails/show/AccessControlListExample</a>
# and <a href="http://wiki.rubyonrails.com/rails/show/LoginGeneratorAccessControlList">http://wiki.rubyonrails.com/rails/show/LoginGeneratorAccessControlList</a>

class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles
  validates_presence_of :name, :info
  validates_uniqueness_of :name
  
  # after_save :delete_users_permission_cache  
  def self.default(name, department)
    new(:name => name + '/@' + department.name.decamelize, 
        :info => 'Grants ' + name + ' access for ' + department.name + '.')
  end
  
  def self.shifts_department_admin_permission(department)
    new(:name => 'shift_admin/@' + department.name.decamelize + '/department_admin', 
        :info => 'Grants shift_admin department admin access for ' + department.name + '.')
  end
  
  def delete_users_permission_cache
    roles.collect(&:users).flatten.uniq.each { |u| u.delete_permission_cache }
  end
  
end