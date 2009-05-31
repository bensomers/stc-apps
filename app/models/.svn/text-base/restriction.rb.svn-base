class Restriction < ActiveRecord::Base
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :location_groups
  belongs_to :department
  belongs_to :for_department,
              :class_name => "Department",
              :foreign_key => "for_department_id"
  
  validate :department_or_locations_and_groups
  
  named_scope :not_yet_expired, lambda{ {:conditions => ["expires > ? OR expires is NULL", Time.now]}}
  
  def validate
    errors.add("Time between start and expiration") if expires and starts >= expires
    errors.add(:hours_limit, "or max subs must be specified") if hours_limit <= 0 unless max_subs
    errors.add(:max_subs, "or hours limit must be specified") if max_subs <= 0 unless hours_limit
  end
  
  def department_or_locations_and_groups
    if locations.empty? and location_groups.empty?
      errors.add(:department_id, " or location(s) and/or location group(s) must be specified") if department.nil?
    end
  end
  
  def self.active(department)
    r = []
    for restriction in find :all, :conditions => ["starts <= ? and department_id = ?", Time.now, department.id]
      r << restriction if !restriction.expires or restriction.expires >= Time.now
    end
    r
  end
  
  def self.upcoming(department)
    find :all, :conditions => ["starts > ? and department_id = ?", Time.now, department.id]
  end

  def end_time
    expires.nil? ? 'infinity (unless this restriction is lifted)' : expires.to_s(:short_name)
  end

  def expires_with_inf_considered
    expires.nil? ? 100.years.from_now : expires
  end
      
end
