class Group < ActiveRecord::Base

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :users
  has_and_belongs_to_many :departments
  
  validates_presence_of :name, :info
  validates_uniqueness_of :name
  validate :must_belong_to_department

  # after_save :delete_users_permission_cache
  #overwrite the origianl all to have it ordered by 'name' ASC -H
  named_scope :all, :order => 'name'
  
  def permission_strings
    self.roles.collect(&:permission_strings).flatten
  end

  private
  def must_belong_to_department
    errors.add("Group must belong to at least one department.", "") if self.departments.empty?
  end
  def delete_users_permission_cache
    users.each { |u| u.delete_permission_cache }
  end
  
end
