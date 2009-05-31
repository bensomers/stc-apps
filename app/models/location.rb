class Location < ActiveRecord::Base
  belongs_to :location_group
  
  has_many :shifts
  has_many :time_slots  
  has_and_belongs_to_many :data_objects
  has_and_belongs_to_many :restrictions
  has_and_belongs_to_many :announcements

  attr_accessor :prior  
  attr_accessor :people_count
  attr_accessor :bar
  attr_accessor :open_at
  attr_accessor :num_row
  
  attr_accessor :at_row#not used yet  
  attr_accessor :bar_id #HTML element id
  
  alias_attribute :name, :short_name
  
  validates_presence_of :short_name, :long_name
  validates_uniqueness_of :short_name, :long_name
  validates_numericality_of :max_staff, :min_staff
  
  named_scope :active, :conditions => {:active => true}
  named_scope :inactive, :conditions => {:active => false}

  def all_shifts_between(start_date, end_date)
    start_time = start_date + location_group.start
    end_time = end_date + location_group.end
    shifts.all_scheduled_between(start_time, end_time)
  end

  def all_shifts_on(date)
    all_shifts_between(date, date)
  end

  def all_time_slots_between(start_date, end_date)
    start_time = start_date + location_group.start
    end_time = end_date + location_group.end
    time_slots.all_between(start_time, end_time)
  end

  def all_time_slots_on(date)
    all_time_slots_between(date, date)
  end
  
  def check_status(t)
    if not open_at[t.to_s(:am_pm)]
      'bar_inactive'
    elsif (people_count[t.to_s(:am_pm)] >= max_staff)
      'bar_full'
    elsif (t<Time.now)
      'bar_passed'
    elsif pending?(t) #because of priority
      'bar_pending'
    else
      'bar_active'
    end
  end

  def count_people_for(shift_list, min_block)
    self.people_count = {}
    self.people_count.default = 0
    unless shift_list.nil?
      shift_list.each do |sh|
        t = sh.start
        while (t<sh.end)
          t += min_block
          self.people_count[t.to_s(:am_pm)] += 1
        end
      end
    end
    people_count
  end
    
  def apply_time_slot_in(day_start, day_end, min_block)
    #get open timeslot on the day: date is Date object and when converted to time, its time is at midnight
    slots = time_slots.find(:all, :conditions => ['start >= ? AND end <= ?', day_start, day_end])
    
    self.open_at = {}
    self.open_at.default = false
    
    slots.each do |ts|
      t = ts.start
      while (t<ts.end)
        t += min_block
        self.open_at[t.to_s(:am_pm)] = true
        #logger.debug { "#{loc.long_name} opens at #{t.to_s(:am_pm)}" } if ts                   
      end
    end
    open_at
  end
  
  def create_bar(day_start, day_end, min_block)
    self.bar = []
    block_start = day_start
    
    while (block_start < day_end)
      t = block_start + min_block
      free_status = check_status(t)

      while (check_status(t)==free_status) and (t<=day_end)
        t += min_block
      end
      
      self.bar << [block_start, (t - min_block), free_status]
      block_start = t - min_block
    end
    bar
  end
  
  def bar_no_active?
    bar_no_active_flag = true
      bar.each do |b|
        if b[2]=='bar_active' or b[2]=='bar_pending'
          bar_no_active_flag = false
          break
        end
      end
    bar_no_active_flag
  end
  
  #item_list can be a list of shifts or template_items or time_slots
  #call this on list of shifts/template_items per location, TTO for example, to assign which row to display the item on.
  #and to know the number of rows to display items
  def label_row_for(item_list)
    row_num = 1
    if item_list and not item_list.empty?
      #initialize all shifts as unassigned to any rows
      item_list.each {|s| s.row = nil}
        
      item_list = item_list.sort_by(&:start)#essential
      #keept track of the latest busy time of all rows
      row_end_time = [item_list.first.start] #note that index starts from 0      
      
      #assign each shfit to the first row it fits into
      item_list.each do |curr_item|
        for i in 0..row_num-1 #check if we can fit this shift in any row
          if row_end_time[i] <= curr_item.start
            curr_item.row = i
            row_end_time[i] = curr_item.end #update latest endtime of row
            break
          end
        end 
  
        if curr_item.row.nil?
          curr_item.row = row_num
          row_end_time[row_num] = curr_item.end
          row_num += 1
        end 
      end
    end
    row_num += 1 #add one row for sign_up bar    
    self.num_row = row_num
  end

  def flatten_one_row(item_list)
    ret = []
    if item_list and not item_list.empty?
      #initialize all shifts as unassigned to any rows
      item_list.each {|s| s.row = nil}
        
      item_list = item_list.sort_by(&:start)#essential
      #keept track of the latest busy time of all rows
      ret << item_list.first
      
      #assign each shfit to the first row it fits into
      item_list.each do |curr_item|
        if ret.last.end < curr_item.start
          ret << curr_item
        end

        if ret.last.end < curr_item.end
          ret.last.end = curr_item.end
        end 
      end
    end
    ret
  end      
  # def create_bar_old(loc) #this one breaks down in to 0, 1, 2, etc people instead of full or not full
  #   bar = []
  #   block_start = @start_time
  #   
  #   while (block_start < @end_time)      
  #     t = block_start + @min_block
  #     logger.debug { "    Time t = #{t}" }      
  #     num = loc.people_count[t.to_s(:am_pm)]
  #     while (loc.people_count[t.to_s(:am_pm)]==num) and (t<=@end_time)
  #       t += @min_block
  #     end
  #     #bar << [block_start.to_s(:am_pm), (t-@min_block).to_s(:am_pm), num]
  #     bar << [block_start, (t-@min_block), num]
  #     block_start = t-@min_block
  #   end
  #   bar    
  # end
  
  def all_unexpired_restrictions
    @a ||= restrictions.not_yet_expired | location_group.restrictions.not_yet_expired | location_group.department.restrictions.not_yet_expired    
  end
  
  def min_staff_not_met?(t)
    open_at[t.to_s(:am_pm)] && people_count[t.to_s(:am_pm)] < min_staff
  end
  
  def pending?(t)
    @p ||= {}
    @p[t] ||= prior and (prior.min_staff_not_met?(t) or prior.pending?(t))
  end
  
  def display_all_links
  #returns an array of html links
    useful_links = location_group.department.shift_configuration.useful_links.to_s + 
      location_group.useful_links.to_s + self.useful_links.to_s
    return useful_links.split(",")    
  end
  
  def display_links
    links = self.useful_links.to_s.split(",")
    display = []
    links.each_index do |i|
      display << [i, links[i]]
    end
    display
  end
  
end
