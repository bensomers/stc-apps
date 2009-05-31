class ShiftReport < ActiveRecord::Base
  has_many :line_items
  belongs_to :shift
  
  validates_presence_of :start
  
  def short_display
     shift.location.short_name + ', ' + start.to_s(:just_date) + ' ' + start.to_s(:am_pm) + '-' + self.end.to_s(:am_pm)
  end
  
  def long_display
     shift.location.long_name + " on " + start.to_s(:just_date_long) + " from " + start.to_s(:am_pm) + " to " + self.end.to_s(:am_pm)
  end

  #when start and end dates are far apart (for forgotten shift reports etc)
  def detailed_time_display
    shift.location.long_name + ', logged in from ' + start.to_s(:short_name) + ' to ' + self.end.to_s(:short_name)    
  end
    
  #need lambda for Time.now to execute everytime it's called
  named_scope :recent, lambda {{:conditions => ["end > ? AND end < ?", 1.week.ago, Time.now], :order => "start"}} 
  #get all unsubmitted reports, this is better then find_all_by_end(nil) because it supports nesting and more functions
  #eg. we can call ShiftReport.all_unsubmitted.count, or ShiftReport.all_unsubmitted.recent, etc. -H
  named_scope :all_unsubmitted, :conditions => ["end is NULL"], :order => "start"
  named_scope :payform_not_auto, :conditions => {:payform_auto_added => false}
  

  # submitting the report; # returns true/false based on report being submitable
  def submit
    if self.submitted?
      false
    else
      self.end = Time.now
      self.save #if fail, validation errors are displayed
      true  
    end
  end
  
  # alias for readability ~Ahmet
  def submitted?
    not self.end.nil?
  end
  
  def self.find_current_report(user)
    report = nil
    shift_reports = ShiftReport.all_unsubmitted
    for shift_report in shift_reports
      if !shift_report.shift
        shift_report.destroy
      elsif user == shift_report.shift.user
        report = shift_report
      end
    end
    #report returns the latest unsubmitted report, since all_unsubmitted is sorted by start time
    report
  end
    
  # method that adds line items to a shift. not safe!
  # action calling it should make sure to verify that shift hasn't been submitted yet.
  def line_add(content,can_edit = false) # AA
    #some safety from following check
    return if self.submitted?
    LineItem.create(:time => Time.now, :can_edit => can_edit, :line_content => content, :shift_report => self)
  end
  
  def check_ip(request, submit_flag = false, admin_name = nil)
    #Used to check for user IP address changes
    #using HTTP_X_FORWARDED_FOR because of proxies.  remote_addr only works on localhost for us.
    new_ip = (request.headers['HTTP_X_FORWARDED_FOR'] || request.remote_addr).to_s
    if login_ip.nil?
      self.logout_ip = self.login_ip = new_ip 
      line_add("logged in on " + start.to_s(:just_date) + " from IP " + login_ip)
    end
    
    unless logout_ip == new_ip
      self.logout_ip = new_ip
      line_add("IP changed to " + new_ip)
    end
    
    if submit_flag
      msg = "logged out on " + Time.now.to_s(:just_date) + " from IP " + new_ip
      msg += " by #{admin_name}" if admin_name
      line_add msg
    end
    save!
  end  

end
