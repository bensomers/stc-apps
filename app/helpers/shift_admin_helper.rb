module ShiftAdminHelper
  def light_print_cell(type, from, to, object = nil, content = "")
    span = (to - from) / @dept_gran #DON'T HARD CODE GRANULARITY UGH! :P
    return '' if span==0
    content = object.user.name if object.class==ShiftTemplateItem
    "<td class='%s' colspan='%s'>%s</td>" % [type, span, content]
  end
  
  #use this instead of order_by because we want an array, not ordered hash
  def split_items_by_days(list)
    a = [[], [], [], [], [], [], []]
    list.each { |e| a[e.wday] << e }
    a
  end

  #here items can be shifts ot time_slots
  def split_to_days(week_items)
    wd = [ [], [], [], [], [], [], [] ]
    for item in week_items
      num = item.start.wday
      wd[num] << item
    end
    wd
  end
  
  def report_links_group_select
    link_group_select = []
    link_group_select.push([@department.name, "department" + @department.id.to_s]) if department_admin?
#    @link_group_select.push(["----------", nil])
    link_group_select = @link_group_select|(@location_groups.map{|lg|[lg.short_name, "lg" + lg.id.to_s]})
#    @link_group_select.push(["----------", nil])
    link_group_select = @link_group_select|(@locations.map{|loc|[loc.short_name, "loc" + loc.id.to_s]})
    return link_group_select
  end
  
end
