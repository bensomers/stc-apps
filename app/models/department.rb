class Department < ActiveRecord::Base
  belongs_to :permission, :dependent => :destroy #if delete department, also delete user_admin permission -H

  has_and_belongs_to_many :users
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups
  
  has_many :data_types
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # after_save :delete_users_permission_cache
  #overwrite the original all to have it ordered by 'name' ASC
  named_scope :all, :order => 'name'
  
  def department_name_not_all
    errors.add("Department cannot have name \"All\"", "") if self.name == "All"
  end
  
  
  #------------------------------------------------------------------------
  #PAYFORM:
  #------------------------------------------------------------------------
  has_many :payforms
  has_many :categories
  has_one  :payform_configuration, :dependent => :destroy# -H
  has_many :clocks
  has_many :mass_clocks
  has_many :payform_items
  
  #------------------------------------------------------------------------
  #SHIFTS:
  #------------------------------------------------------------------------
  has_many :location_groups
  has_one :shift_configuration, :dependent => :destroy #-H
  has_many :time_templates
  has_many :shift_templates
  has_many :data_types
  has_many :restrictions
  has_many :announcements

  def before_destroy
    #delete all roles that only belong to this department -H
    #permissions under each of these roles are taken care of in role.rb
    self.roles.each { |role| role.destroy if role.departments.size==1 }    
  end

  def delete_users_permission_cache
    users.each { |u| u.delete_permission_cache }
  end
  
  def rename_roles_and_permissions_and_groups(new_name)
    old_name = self.name.decamelize
    self.roles.map{|r|r.permissions}.flatten.uniq.reject{|p|not p.name.include?("@" + old_name)}.each do |perm|
      perm.update_attributes(
        :name => perm.name.gsub(("@" + old_name), ("@" + new_name.decamelize))
        )
    end
    self.roles.reject{|r|not r.name.include?("@" + old_name)}.each do |role|
      if role.display_name.include?(self.name)
        new_display_name = role.display_name.gsub(self.name, new_name)
      else
        new_display_name = role.display_name
      end
      role.update_attributes(
        :name => role.name.gsub(("@" + old_name), ("@" + new_name.decamelize)),
        :display_name => new_display_name
        )
    end
    self.groups.reject{|g|not g.name.include?(self.name)}.each do |group|
      group.update_attributes(:name => group.name.gsub(self.name, new_name))
    end
  end
  
end
