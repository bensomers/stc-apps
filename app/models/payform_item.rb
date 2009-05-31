class PayformItem < ActiveRecord::Base
  has_many    :edit_items
  has_and_belongs_to_many  :payforms
  belongs_to  :category
  belongs_to  :mass_clock
  belongs_to :department
  
  belongs_to :mass_job, :class_name => "PayformItem", :foreign_key => "mass_job_id"
  has_many :flattened_jobs, :class_name => "PayformItem", :foreign_key => "mass_job_id"
  
  validates_presence_of :department
  validates_presence_of :date
  validates_presence_of :reason, :unless => :active?
  validates_numericality_of :hours
  validates_associated :edit_items
  
  named_scope :in_category, lambda { |cat_id| { :conditions => ['category_id = ?', cat_id] } }
  named_scope :in_department, lambda { |dept_id| { :conditions => ['department_id = ?', dept_id] } }
  named_scope :active, lambda { |*args| { :conditions => ['active = ?',  true] } }
  named_scope :mass, lambda { |*args| { :conditions => ['mass = ?', true] } }

  def div_id
    "job" + self.id.to_s
  end

  protected
    
  def validate
    errors.add(:hours, "should be feasible: \'" + hours.to_f.to_s + "\' is invalid" ) if (hours.nil? || hours > 24 || hours <= 0) and active
    errors.add(:reason, "seems too short") if !active and reason.length < department.payform_configuration.reason_min
    errors.add(:description, "seems too short") if description.length < department.payform_configuration.description_min
    errors.add("Can't Have More Than One Payform") if self.payforms.length>1 and mass == false
    errors.add(:date, "is invalid") if !Date.valid_civil?(date.year, date.month, date.day)
    errors.add(:date, "cannot be in the future") if date > Time.now.to_date
  end
  
end
