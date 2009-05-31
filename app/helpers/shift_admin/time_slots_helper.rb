module ShiftAdmin::TimeSlotsHelper
  def label_slot(slot)
    slot.date < Date.today ? 'passed' : 'shift_time'
  end
  
  def th_with_description(ts)
    "<th title='%s'>%s</th>" % [ts.date.to_s(:long), ts.date.to_s(:day)]
  end
  
end
