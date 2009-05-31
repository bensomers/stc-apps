module PayformApplicationHelper
  def hours(payform_items)
    payform_items.to_a.sum do |p|
      p.active? ? p.hours : 0
    end
  end

  def is_admin?
    controller.controller_name == "payform_admin"
  end

  def selected_hours(payform_item)
    payform_item and payform_item.hours ? payform_item.hours.floor : 0
  end
  
  def selected_min(payform_item)
    payform_item and payform_item.hours ? ((payform_item.hours - payform_item.hours.floor)*60.0 ).round : 0
  end

end
