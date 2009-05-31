class TimeTemplate < Library
  validates_uniqueness_of :name
  
  
  def time_template_items
    template_items
  end

  def items_with_validate
    items = self.template_items
    items.map! do |item|
      item.status = "valid"
      item.comment = "valid"
      (item.start..item.end).step(granularity).reverse.each do |time|
        time_conflicts = items.select { |i| (i.id != item.id) and (i.location_id == item.location_id) and (i.wday == item.wday) and (i.start <= time) and (i.end > time)}
        unless time_conflicts.empty?
          item.status = "crowded"
          item.comment = "#{time_conflicts.length} items at #{time.min_to_am_pm}"
        end
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
