class TimeTemplateItem < TemplateItem
  
  def apply_to_date(date)
    if date.wday == self.wday
      timehash = {}
      timehash[:start] = date + self.start.minutes
      timehash[:end] = date + self.end.minutes
      timehash[:location_id] = self.location_id
      timehash
    else
      nil
    end
  end
end
