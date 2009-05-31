class Sticky < Notice
  belongs_to :remover,
              :class_name => "User",
              :foreign_key => "remover_id"
        
  #I believe this method and marked? are dead code              
  def mark
    @marked = true
  end
  
  def marked?
    @marked || false
  end
  
  def self.find_all_active
    find_all_by_end_time(nil).sort_by {|x| [x.start_time]}
  end
  
  def active?
    self.end_time.nil?
  end
  
  def remove(user)
    self.errors.add_to_base "This sticky has already been cleared by #{remover.name}" and return unless active?
    self.remover = user
    self.end_time = Time.now
    true
  end
  
  def self.make(hash = {})
    sticky = new(hash)
    sticky.start_time = Time.now
    sticky
  end
  

  def locations(get_objects = false)
    array = auth_locations.split.map &:to_i
    array = Location.find(array) if get_objects
    array
  end
  
  def locations=(array)
    array ||= []
    array.map! &:id if array.first.class == Location
    self.auth_locations = array.join " "
  end
  
  def location_groups(get_objects = false)
    array = auth_location_groups.split.map &:to_i
    array = LocationGroup.find(array) if get_objects
    array
  end
  
  def location_groups=(array)
    array ||= []
    array.map! &:id if array.first.class == LocationGroup
    self.auth_location_groups = array.join " "
  end


end
