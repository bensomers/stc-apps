class TemplateItem < ActiveRecord::Base
  has_many :template_items
  belongs_to :location
  belongs_to :library
  
  validates_presence_of :library_id, :location_id, :start, :end
  
  attr_accessor :delete
  attr_accessor :row
  
  attr_writer :status
  def status
    @status ||= ""
  end
  
  attr_accessor :comment
  
  attr_writer :locations
  def locations
    @locations ||= Array.new
  end
  
  attr_writer :days
  def days
    @days ||= Array.new
  end
  
  def start_minute
    return 0 if self.start.nil?
    self.start.modulo(60)
  end
  def start_minute=(min)
    min = min.to_i
    self.start = self.start - self.start_minute + min
    self.calibrate_time
  end
  def end_minute
    return 0 if self.end.nil?
    self.end.modulo(60)
  end
  def end_minute=(min)
    min = min.to_i
    self.end = self.end - self.end_minute + min 
    self.calibrate_time
  end
  
  def start_am_pm
    return 0 if self.start.nil?
    tempstart = self.start % (24*60)
    tempstart / (60 * 12)
  end
  def start_am_pm=(ampm)
    ampm = ampm.to_i
    self.start = self.start % (60 * 12) + ampm * (60*12)
    self.calibrate_time
  end
  def end_am_pm
    return 0 if self.end.nil?
    tempend = self.end % (24*60)
    tempend / (60 * 12)
  end
  def end_am_pm=(ampm)
    ampm = ampm.to_i
    self.end = self.end % (60 * 12) + ampm * (60*12)
    self.calibrate_time
  end
  
  def start_hour
    return 0 if self.start.nil?
    (self.start / 60) % 12
  end
  def start_hour=(hour)
    hour = hour.to_i
    full = self.start_full
    full[0] = hour
    self.start_full=full
    self.calibrate_time
  end
  def end_hour
    return 0 if self.end.nil?
    (self.end / 60) % 12
  end
  def end_hour=(hour)
    hour = hour.to_i
    full = self.end_full
    full[0] = hour
    self.end_full=full
    self.calibrate_time
  end
  
  def start_full
    [start_hour, start_minute, start_am_pm]
  end
  def end_full
    [end_hour, end_minute, end_am_pm]
  end

  def start_full=(full)
    self.start = (full[0] + full[2]*12)*60 + full[1]
    self.calibrate_time
  end
  def end_full=(full)
    self.end = (full[0] + full[2]*12)*60 + full[1]
    self.calibrate_time
  end
  
  def calibrate_time
    unless self.library.nil?
      self.start += 24 * 60 if (self.start < self.library.start)
      self.end += 24 * 60 if (self.end < self.library.start)
    end
  end
  
  def start_to_s
    full = self.start_full
    ampm = " AM"
    ampm = " PM" if full[1] == 1
    "%02d" % full[0] + ":" + "%02d" % full[2] + ampm
  end
  def end_to_s
    full = self.end_full
    ampm = " AM"
    ampm = " PM" if full[1] == 1
    "%02d" % full[0] + ":" + "%02d" % full[2] + ampm
  end

end
