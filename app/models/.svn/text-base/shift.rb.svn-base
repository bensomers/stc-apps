require "date"
class Shift < ActiveRecord::Base
  has_one :shift_report, :dependent => :destroy
  has_one :sub
  belongs_to :location
  belongs_to :user

  attr_accessor :row

  validates_presence_of :start, :end, :user_id, :location_id

  #add more parameters to validate for more validation (each being a method name)
  validate :start_less_than_end
  validate :user_duplicate #prevent user with overlapping shifts
  validate :not_in_the_past #prevent shift created for the past
  validate :incorrect_user_name #or netid

  # ===============
  # = named_scope =
  # ===============
  named_scope :since, lambda { |time| {:conditions => ["start >= ?",time] }}

  named_scope :all_between, lambda {|start_time, end_time| {:conditions => ["start >= ? AND start < ?", start_time, end_time], :order => "start"}}
  named_scope :scheduled, :conditions => ['start != end']
  named_scope :unscheduled, :conditions =>  ['start = end']
  named_scope :ended_before, lambda {|time| {:conditions => ["end < ?", time] }}
  named_scope :ended_after, lambda { |time| {:conditions => ["end >= ?",time] }}

  alias_attribute :report, :shift_report

  def self.filter_by_department(dept)
    all.select { |s| s.department==dept }
  end

  def department
    @cache_department ||= location.location_group.department
  end
  # =================
  # = Class Methods =
  # =================
  def self.make(shift_hash)
    shift = Shift.new(shift_hash)

    shift_later = shift_earlier = nil
    if shift.save
      if (shift_later = Shift.find(:first, :conditions => ["start = ? AND user_id = ? AND location_id = ?", shift.end, shift.user_id, shift.location_id]))
       shift.end = shift_later.end
       shift_later.destroy
       shift.save
      end
      if (shift_earlier = Shift.find(:first, :conditions => ["end = ? AND user_id = ? AND location_id = ?", shift.start, shift.user_id, shift.location_id]))
        shift_earlier.end = shift.end
        shift.destroy
        shift_earlier.save
        shift = shift_earlier
      end
    end
    shift
  end

  #using this instead of named_scope beccause eager loading 'include' does not work well with named_scope -H
  def self.all_scheduled_between(start_time, end_time)
    find :all, :conditions => ["start >= ? AND start < ? AND start!=end", start_time, end_time], :include => :shift_report
  end

  # ==================
  # = Object methods =
  # ==================
  def too_early?
    start > 30.minutes.from_now
  end

  def missed?
    has_passed? and !signed_in?
  end

  def late?
    signed_in? && (shift_report.start - start > department.shift_configuration.grace_period.minutes)
  end

  #a shift has been signed in to if it has a shift report
  def signed_in?
    (shift_report)
  end

  #a shift has been signed in to if its shift report has been submitted
  def submitted?
    (shift_report) and (shift_report.end)
  end

  #check if a shift has a *pending* sub request and that sub is not taken yet
  def has_sub?
    #note: if the later part of a shift has been taken, self.sub still returns true so we also need to check self.sub.new_user.nil?
    sub and sub.new_user.nil? #new_user in sub is only set after sub is taken.  shouldn't check new_shift bcoz a shift can be deleted from db. -H
  end

  def has_sub_at_start?
    has_sub? and start == sub.start
  end

  def has_passed?
    self.end < Time.now
  end

  def has_started?
    self.start < Time.now
  end

  def scheduled?
    self.start != self.end
  end

  def ok_to_sign_up?
    not (exceed_max? or on_invalid_time_slot? or exceed_restriction? or violate_loc_group_restrictions?)
  end

  # ===================
  # = Display helpers =
  # ===================
  def short_display
     self.location.short_name + ', ' + self.start.to_s(:just_date) + ' ' + self.start.to_s(:am_pm) + '-' + self.end.to_s(:am_pm)
  end

  def short_name
    self.location.short_name + ', ' + self.user.name + ', ' + self.start.to_s(:am_pm) + '-' + self.end.to_s(:am_pm) + ", " + self.start.to_s(:just_date)
  end

  def short_name_unscheduled
    self.location.short_name+ ', ' + self.user.name + ', ' + self.shift_report.start.to_s(:am_pm) + '-' + self.shift_report.end.to_s(:am_pm) + ", " + self.start.to_s(:just_date)
  end
  
  def short_name_kilroy
    (self.shift_report.start - 7.hours).strftime("%a") + ' - ' + self.user.name + ', ' + self.shift_report.start.to_s(:am_pm) + '-' + self.shift_report.end.to_s(:am_pm)+ ", " + self.shift_report.start.to_s(:just_date)
  end

  def long_display
     location.long_name + " on " + start.to_s(:just_date_long) + " from " + start.to_s(:am_pm) + " to " + self.end.to_s(:am_pm)
  end

  def long_display_with_name
    user.name + ', ' + long_display
  end

  def parent_div
    shift_date.to_s
  end

  def sign_up_div
    "quick_sign_up_" + shift_date.to_s
  end

  def sign_in_div
    "quick_sign_in_" + shift_date.to_s
  end

  # ======================
  # = Virtual attributes =
  # ======================
  def shift_date #they day of shifts that it corresponds to (1 a.m. shifts are the previous day, so you CAN'T just get the date)
    return nil if self.start.nil?
    if start.to_time.seconds_since_midnight/60 < department.shift_configuration.start
      start.to_date.yesterday
    else
      start.to_date
    end
  end

  #@date is necessary for certain forms to save date column properly
  def date
    @date || shift_date
  end

  def date=(d)
    @date = Date.parse(d)
  end

  def end_of_grace
    start + department.shift_configuration.grace_period.minutes
  end

  #assign user_id if user_name is given
  #find_ by_name returns nil if u_n is invalid
  def user_name=(u_n)
    @name = u_n
    self.user = User.find_by_name(u_n) || User.find_by_login(u_n)
  end

  def user_name
    @name || (self.user ? self.user.name : nil)
  end

  def duration
    self.end - start
  end

  def location_group_id
    location.location_group_id
  end

  def department_id
    department.id
  end

  def self.wipe(locations, start, stop = start + 1.day)
    # takes in a list of locations, a start and an optional end date. wipes everything.
    locations.each do |location_id|
      shifts = Shift.find(:all, :conditions => ["location_id = ? && start <= ? && end >= ?", location_id, stop, start])
      for shift in shifts
        if shift.report
          shift.start = shift.end
        else
          shift.destroy
        end
      end
    end
  end

  private

  # ======================================================
  # = Manual validation (so that admin can by pass this) =
  # ======================================================
  def exceed_max?
    #check every minute block (jump by granularity) to see the max number of overlapping shifts for this shift
    time_step = department.shift_configuration.granularity.minutes #convert to seconds, to be compatible with Time object
    max = self.location.max_staff
    name = self.location.short_name

    block_end = self.start
    c = 0

    while (block_end += time_step) < self.end
      c = self.location.shifts.count(:all, :conditions => ['(start < ? AND end >= ? AND user_id != ?)', block_end, block_end, user_id])
      # only checks shifts that aren't yours, since user_duplicate takes care of yours.
      break if (c>=max)
    end

    #this is needed to be generic, works even when (time_step does not divide (end-start))
    if c<max
      c = self.location.shifts.count(:all, :conditions => ['(start < ? AND end >= ? AND user_id != ?)', self.end, self.end, user_id])
      block_end = self.end
    end

    errors.add_to_base("Max exceeded: more than #{c} people working in the #{name} at the same time (at #{block_end.to_s(:am_pm)}).") if (c>=max)
    !errors.empty?
  end

  def on_invalid_time_slot?
    c = TimeSlot.count(:all, :conditions => ['start <= ? AND end >= ? AND location_id = ?', start, self.end, location_id])
    errors.add_to_base("Part or whole of shift does not have a time slot for it") if c.zero?
    !errors.empty?
  end

  def exceed_restriction?
    restrictions = location.all_unexpired_restrictions.reject {|r| r.hours_limit.blank?}
    restrictions.each do |r|
      max = r.hours_limit
      #TODO: Is this department independent??? all scheduled shifts needs to be IN THE DEPARTMENT or it accounts for shifts that it shouldn't.
      shift_time_so_far = user.shifts.scheduled.all_between(r.starts, r.expires_with_inf_considered).collect(&:duration).sum
      if (h = shift_time_so_far + (self.end - start)) > max.hours
        errors.add_to_base("Maximum hours exceeded: #{h/3600.0} hours, over #{max} hours allowed between #{r.starts.to_s(:short_name)} and #{r.end_time}")
      end
    end
    !errors.empty?
  end

  def violate_loc_group_restrictions?
    max_length = location.location_group.max_shift_length
    min_length = location.location_group.min_shift_length
    dur = self.end - self.start

    #potential length after joining
    if (shift_later = Shift.find(:first, :conditions => ["start = ? AND user_id = ? AND location_id = ?", self.end, user_id, location_id]))
      dur += shift_later.end - shift_later.start
    end
    if (shift_earlier = Shift.find(:first, :conditions => ["end = ? AND user_id = ? AND location_id = ?", start, user_id, location_id]))
      dur += shift_earlier.end - shift_earlier.start
    end

    errors.add_to_base("Shift too short. Minimum is #{min_length} hours, but yours is #{dur/3600}") if min_length and dur < min_length.hours
    errors.add_to_base("Shift too long. Maximum is #{max_length} hours, but yours is #{dur/3600} (adjacent shifts joined)") if max_length and dur > max_length.hours
    # MY_LOGGER.debug("duration: #{duration/3600.0}")
    !errors.empty?
  end
  # ======================
  # = Validation helpers =
  # ======================
  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end < start)
  end

  def user_duplicate
    unless self.start == self.end  #allow users to sign into blank report even if they have an overlapping shift
      c = Shift.count(:all, :conditions => ['user_id = ? AND start < ? AND end > ?', self.user_id, self.end, self.start])
      unless c.zero?
        errors.add_to_base("#{self.user.name} has an overlapping shift in that period") unless (self.id and c==1)
      end
    end
  end

  def not_in_the_past
    errors.add_to_base("Can't sign up for a time slot that has already passed!") if self.end + 1.minute < Time.now
  end

  #used to check invalid name in auto complete
  def incorrect_user_name
    if user_name and user_id.nil?
      errors.clear
      errors.add_to_base("User with name or netid #{user_name} not found!")
    end
  end

end
