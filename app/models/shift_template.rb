class ShiftTemplate < Library
  validates_uniqueness_of :name
  
  
  def shift_template_items
    template_items
  end
    
    
  def items_with_validate
    items = self.template_items
    items.map! do |item|
      item.status = "valid"
      (item.start..item.end).step(granularity).reverse.each do |time|
        time_conflicts = items.select { |i| (i.location_id == item.location_id) and (i.wday == item.wday) and (i.start <= time) and (i.end > time) }
        if time_conflicts.length > item.location.max_staff
          item.status = "crowded"
          temp = time.min_to_am_pm
          item.comment = "#{time_conflicts.length} at #{temp} (max #{item.location.max_staff})"
        end
      end
      user_conflicts = items.select { |i| (i.user == item.user) and (i.id != item.id) and (i.wday == item.wday) and (i.start < item.end) and (item.start < i.end) }
      unless user_conflicts.empty?
        conflict = user_conflicts.first
        item.comment = "user working #{conflict.location.short_name} @ #{conflict.start.min_to_am_pm}"
        item.comment += " + #{user_conflicts.length} others" unless user_conflicts.length == 1
        item.comment += " + overcrowded" if item.status == "crowded"
        item.status = "user_conflict"
      end
      if (item.start < self.start) or (item.end > self.end)
        item.status = "out_of_range"
        item.comment = "out of range (#{self.start.min_to_am_pm}-#{self.end.min_to_am_pm}"
      end
      item
    end
    items.sort_by {|t| [t.wday,t.start] }
  end
  
end
