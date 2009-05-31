class Announcement < Notice
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :location_groups
  belongs_to :department
  belongs_to :for_department,
              :class_name => "Department",
              :foreign_key => "for_department_id"
  
  validate :department_or_locations_and_groups
  validates_presence_of :content
  
  named_scope :not_yet_ended, lambda{ {:conditions => ["end_time > ? OR end_time is NULL", Time.now]} }
  
  def validate
    errors.add("Time between start and expiration") if end_time and start_time >= end_time
  end
  
  def department_or_locations_and_groups
    if locations.empty? and location_groups.empty?
      errors.add(:department_id, " or location(s) and/or location group(s) must be specified") if department.nil?
    end
  end
  
  def self.active(department)
    r = []
    for announcement in find :all, :conditions => ["start_time <= ? and department_id = ?", Time.now, department.id]
      r << announcement if !announcement.end_time or announcement.end_time >= Time.now
    end
    r
  end
  
  def self.upcoming(department)
    find :all, :conditions => ["start_time > ? and department_id = ?", Time.now, department.id]
  end
  
  
  def authorized?(object)
    result = case object
      when LocationGroup: "for location group #{object.short_name}" if location_groups.include? object
      when Location: "for location #{object.short_name}" if locations.include? object
      #when User: "for user #{object.name}" if users.include? object.id
      #comment: i think all the users should be displayed, otherwise a user might trash a sticky that was supposed to be addressed to more than one person -snl
      when User: "for users #{self.user_names}" if users.include? object
      when Department: "for department #{object.name}" if for_department == object
    end
    #self.auth_text = result
    self.auth_text = self.auth_full_list if result
  end
  
end
