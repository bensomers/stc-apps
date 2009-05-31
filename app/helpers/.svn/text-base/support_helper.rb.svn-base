module SupportHelper
  def print_shift_block(type, from, to, shift = nil, content = "")
    span = ((to - from) / @dept_gran.minutes).round
    return '' if span==0
    if shift
      content += from.to_s(:twelve_hour) + ' - ' + to.to_s(:twelve_hour)
    end
    "<td class='%s' colspan='%s'>%s</td>" % [type, span, content]
  end
  
  #use this instead of group_by because we want an array
  def split_to_rows(item_list)
    items_in_row = [[]]
    if item_list
      item_list.each do |sh|
        items_in_row[sh.row] ||= []
        items_in_row[sh.row] << sh
      end
    end
    items_in_row
  end

end
