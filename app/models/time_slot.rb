class TimeSlot < ActiveRecord::Base
  belongs_to :location
  validate :end_greater_than_now
  validate :start_greater_than_end
  attr_accessor :row

  named_scope :all_between, lambda {|start_time, end_time| {:conditions => ["start >= ? AND start < ?", start_time, end_time], :order => "start"}}
  named_scope :since, lambda { |time| {:conditions => ["start >= ?",time], :order => "start DESC"} }
  def can_sign_up?
    self.end > Time.now
  end
  
  def date
    self.start.to_date
  end

  def start_in_minute
    (self.start.seconds_since_midnight/60).floor
  end  
  def end_in_minute
    ((self.end - self.start.midnight)/60).floor
  end
  
  def end_greater_than_now
    errors.add_to_base("Time slot not active because it has passed.") if self.date < Date.today
  end  
 
  def start_greater_than_end
    errors.add_to_base("Start time must be earlier than end time") if self.start >= self.end
  end
  
  def self.make(time_slot_hash, clear = false)
    time_slot = TimeSlot.new(time_slot_hash)
    return time_slot if time_slot.end_greater_than_now
    if clear
      TimeSlot.wipe(time_slot.location_id,time_slot.date)
    else
      conflicts = TimeSlot.find(:all, :conditions => ["location_id = ? && start <= ? && end >= ?", time_slot.location_id, time_slot.end, time_slot.start])
      time_slot.start = (conflicts + [time_slot]).map {|t| t.start}.min
      time_slot.end = (conflicts + [time_slot]).map {|t| t.end}.max
      conflicts.each do |c|
        c.destroy
      end
    end
    time_slot.save
    time_slot
  end
  
  def self.wipe(locations, start, stop = start + 1.day)
    # takes in a list of locations, a start and an optional end date. wipes everything.
    locations.each do |location_id|
      time_slots = TimeSlot.find(:all, :conditions => ["location_id = ? && start <= ? && end >= ?", location_id, stop, start])
      time_slots.each &:destroy
    end
  end
  
end
