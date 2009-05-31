class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items
  has_many :edit_items
  
  validates_presence_of :name, :department_id
  
  named_scope :active,   lambda { |dept_id| { :conditions => ['department_id = ? and active = true',  dept_id]}}
  named_scope :disabled, lambda { |dept_id| { :conditions => ['department_id = ? and active = false', dept_id]}}    
  
  protected
  
  def validate
    for category in department.categories
        errors.add(:category, "name already taken") if name == category.name and id != category.id
    end
  end
  
end
