class ShiftConfiguration < ActiveRecord::Base  
  belongs_to :department
  belongs_to :shift_permission,
             :class_name => 'Permission', :dependent => :destroy
  belongs_to :shift_admin_permission,
             :class_name => 'Permission', :dependent => :destroy
  belongs_to :department_admin_permission,
             :class_name => 'Permission', :dependent => :destroy
             
  validates_presence_of :department_id
  validates_numericality_of :start, :end
             
  alias_attribute :permission, :shift_permission 
  alias_attribute :admin_permission, :shift_admin_permission 
             
  def self.default
    new(:granularity => 60,
        :start => 540,
        :end => 17*60,
        :grace_period => 0,
        :report_can_edit => false)
  end
  
  def minute_blocks
    (start..self.end).step(granularity)
  end
  
  def calibrate_time
    if self
      self.end += 24*60 if self.end <= self.start
      self.save
    end
  end
  
  def self.permission_name
    'shift'
  end
  
  def self.admin_permission_name
    'shift_admin'
  end
    
  def display_links
    return self.useful_links.to_s.split(",")
  end
    
end
