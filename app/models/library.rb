class Library < ActiveRecord::Base
  
  belongs_to :department
  has_many :template_items

  validates_presence_of :department
  
  attr_accessor :apply_from
  attr_accessor :apply_to
  attr_accessor :template_to_import_from
  
  def start
    @dept_start ||= self.department.shift_configuration.start
  end
  
  def end
    @dept_end ||= self.department.shift_configuration.end
  end
  
  def granularity
    @dept_granularity ||= self.department.shift_configuration.granularity
  end

  def locations
    self.template_items.map{|i| i.location_id}.uniq
  end
 
  def self.new_template(params = nil)
    params ||= {}
    type = params.delete(:type)
    if type == "ShiftTemplate"
      ShiftTemplate.new(params)
    elsif type == "TimeTemplate"
      TimeTemplate.new(params)
    else
      Library.new(params)
    end
  end
  
  def new_item(hash = nil)
    hash ||= {}
    params = hash.dup
      params[:library_id] = self.id
      params[:start] ||= self.start if params[:start_minute].nil? and params[:start_hour].nil? and params[:start_am_pm].nil?
      params[:end] ||= self.end if params[:end_minute].nil? and params[:end_hour].nil? and params[:end_am_pm].nil?
    if self.class == ShiftTemplate
      ShiftTemplateItem.new(params)
    elsif self.class == TimeTemplate
      TimeTemplateItem.new(params)
    else
      TemplateItem.new(params)
    end
  end
  
  def authorized?(user)
    yay = true
    for lg in user.authorized_location_groups(self.department)
      for ti in template_items
        for loc in ti.locations
          yay = false unless loc.location_group == lg
        end
      end
    end
    return yay
  end
  
  def items_to_create=(hash = nil)
    temp_item = new_item(hash)
    temp_item.locations.each do |loc_id|
      temp_item.days.each do |wday|
        item = new_item(hash)
        item.location_id = loc_id
        item.calibrate_time
        item.wday = wday
        item.save!
      end
    end
  end
  
  def import_items_from(library)
    library.template_items.each do |item|
      new_item = item.clone
      new_item.library = self
      new_item.save!
    end
    self.template_items
  end
  
  def export_items_to(library)
    library.import_items_from self
  end
  
  def deep_clone(new_name = nil, new_description = nil)
    new_library = self.clone
    new_library.name = new_name || "Copy of #{self.name}"
    new_library.description = new_description || "Copy of #{self.description}"
    new_library.save!
    
    new_library.import_items_from self
    
    true
  end
  
end
