module ShiftApplicationHelper
  def is_admin?
    controller.controller_name=="shift_admin"
  end

# ==================
# = Report Helpers =
# ==================
  def belongs_to_user?(shift_report)
    shift_report.shift.user == get_user
  end

# =======================
# = Restriction Helpers =
# =======================
  def selected_hours(restriction)
    restriction and restriction.hours_limit ? restriction.hours_limit.floor : 0
  end

  def selected_min(restriction)
    restriction and restriction.hours_limit ? ((restriction.hours_limit - restriction.hours_limit.floor)*60.0 ).round : 0
  end

  def selected_subs(restriction)
    restriction and restriction.max_subs ? restriction.max_subs : 0
  end
# =================
# = Shift Helpers =
# =================
  #needs min_block and @user
  def print_cell(type,from,to,shift=nil,content = "", first_time = true)
    span = ((to - from)/min_block).floor #convert to integer is impt here
    user_info = ""
    br = ""
    #option for link_to:
    link_name = ""
    url_options = {}
    html_options = {} #to pass id and class name to link_to
    td_title = ""

    extra = "" #other stuff to html,like a hidden div, must not contain table elements

    if span.zero?#return nothing if from and to time are the same
      ''
    else
      if (type=="bar_active")
        if @can_sign_up
          link_name = is_admin? ? "schedule" : "sign up"
          url_options = {:action => "sign_up",
                :shift => {:start => shift.start, :end => shift.end, :location_id => shift.location_id} }
          html_options = {:class => "sign_up_link"}

        else
          content = "view only"
          td_title = 'You only have a view access to this cluster, not sign up access.'
        end

      elsif (type=="bar_pending")
        content = '-'
        td_title = 'You may not sign up in this slot until a higher priority location is filled.'

      elsif shift
        if type == 'shift_time'
          type.gsub!(/shift/, 'user') if !is_admin? and shift.user == @user
          if shift.missed?
            type.gsub!(/time/, 'missed_time')
          elsif (shift.signed_in? ? shift.shift_report.start : Time.now) > shift.end_of_grace
            type.gsub!(/time/, 'late_time')
          end
        end

        if span > 3
          user_info = shift.user.name + '<br />' + from.to_s(:twelve_hour) + ' - ' + to.to_s(:twelve_hour)
        else
          user_info = shift.user.login
          td_title = shift.user.name + ',' + from.to_s(:twelve_hour) + ' - ' + to.to_s(:twelve_hour)
        end

        if first_time && shift.has_sub? && (shift.sub.eligible?(@user) || type=="user_time") &&
           (!shift.has_passed? || !shift.sub.new_user)
            before_sub = print_cell("shift_time", shift.start, shift.sub.start, shift, "", false)
            sub_class_name = shift.sub.has_passed? ? (is_admin? ? "sub_missed_time" : "shift_missed_time") : "sub_time"
            sub = print_cell(sub_class_name, shift.sub.start, shift.sub.end, shift, "", false)
            after_sub = print_cell("shift_time", shift.sub.end, shift.end, shift, "", false)

            s = before_sub + sub + after_sub
            return s

        elsif type=="sub_time"
          br = '<br />'
          if is_admin? or shift.user==@user
            con_name = is_admin? ? 'shift_admin' : 'shift'
            link_name = "cancel sub"
            url_options = {:controller => con_name, :action => "sign_in", :id => shift}
            html_options = {:class => "sign_in_link"} unless is_admin?
          else
            link_name = "accept sub"
            url_options = {:controller => "shift", :action => "sub_accept", :id => shift.sub}
            type = "accept_sub"
            html_options = {:onclick => make_popup(:title => 'Accept this sub?')}
          end
          #this prepares sub reason as a popup
          sub = shift.sub
          html_options = {:id => "sub_link_#{sub.id}", :class => "popup_link" }
          extra = render_to_string(:partial => 'shift/sub_reason', :locals => {:sub => sub})

        elsif shift.signed_in? #display shift report
          # link to view report on a new page
          br = '<br />'
          if (shift.user==@user && !shift.submitted?)
            link_name = "return"
            view_action = "view"
            html_options = {}
          else
            link_name = "view"
            view_action = "view_float"
            html_options = {:rel => "floatbox#{shift.location_id}", :rev => "width:500px height:500px" }
          end

          if is_admin?
            url_options = {:action => "view_report", :id => shift.shift_report}
            html_options = {}
          else
            url_options = {:controller => "report", :action => view_action, :id => shift.shift_report}
          end

          #this prepares view report as a popup, only yesterday onwards
          if shift.date >= Date.today
            report = shift.shift_report
            html_options.merge!(:id => "report_link_#{report.id}", :class => "popup_link")
            extra = render_to_string(:partial => 'report/report_popup', :locals => {:report => report})
          end

        elsif type=="user_time" and not shift.has_passed? #if shift belongs to user and can be signed up
          br = '<br />'
          url_options = {:controller => "shift", :action => "sign_in", :id => shift}
          html_options = {:class => "sign_in_link"}
          link_name = "options"

        elsif type=="user_late_time"
          br = '<br />'
          url_options = {:controller => "shift", :action => "sign_in", :id => shift}
          html_options = {:class=> "late_sign_in_link"}
          link_name = "options"

        elsif is_admin? and not shift.has_passed? and not shift.signed_in?
          br = '<br />'
          url_options = {:controller => "shift_admin", :action => "edit_shift", :id => shift}
          link_name = "edit"

        end

      end

      content += user_info + br + link_to(link_name, url_options, html_options)
      "<td title='#{td_title}' class='#{type}' colspan=#{span}>#{content}</td>" + extra
    end
  end

  def make_sub_link
    if @shift.scheduled?
      if @shift.has_sub?
        link_to "Cancel sub request", {:action => "sub_cancel", :id => @shift}, :method => :delete
      else
        link_to "Create a sub request", {:action => "sub_request", :id => @shift},
            is_admin? ? {} : {:onclick => make_popup(:title => 'Request a sub')}
      end
    else
      ''
    end
  end

  def load_variables(loc_group)
    @day_start = @curr_day + loc_group.start
    @day_end = @curr_day + loc_group.end

    @can_sign_up = loc_group.allow_sign_up? get_user
  end

  def populate_loc(loc, shifts)
    loc.label_row_for(shifts) #assigns row number for each shift (shift.row)
    loc.count_people_for(shifts, min_block)#count number of people working concurrently for each time block
    loc.apply_time_slot_in(@day_start, @day_end, min_block)#check if time is valid or not
    loc.create_bar(@day_start, @day_end, min_block)
    loc.bar_id = loc.short_name + @curr_day.to_s
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

  def link_toggle(id, name)
    # "<a href='#' onclick=\"Element.toggle('%s'); return false;\">%s</a>" % [id, name]
    # link_to_function name, "$('#{id}').toggle()"
    link_to_function name, "Effect.toggle('#{id}', 'appear', { duration: 0.3 });"
  end

  def link_toggle_unless(condition, id, name)
    condition ? name : link_toggle(id,name)
  end

  def sign_up_div_id
    "quick_sign_up_%s" % @curr_day
  end

  def sign_in_div_id
    "quick_sign_in_%s" % @curr_day
  end

  def min_block
    session["min_block"]
  end

  def hide_bars(name)
    f = ""
    @bar_ids[@curr_day].each { |id| f << "Effect.Fade('#{id}', { duration: 0.3 });"}
    unless f.empty?
      f << "$(this).up().hide();"
      f << "$(this).up().next().show();"
      link_to_function(name, f)
    end
  end

  def show_bars(name)
    f = ""
    @bar_ids[@curr_day].each { |id| f << "Effect.Appear('#{id}', { duration: 0.3 });"}
    unless f.empty?
      f << "$(this).up().hide();"
      f << "$(this).up().previous().show();"
      link_to_function(name, f)
    end
  end

  def on_time_message
    now = Time.now
    message = is_admin? ? "#{@shift.user.full_name} is " : "You're "
    message += (now > @shift.start) ? "late" : "early"
    message += " by "
    message += distance_of_time_in_words(now-@shift.start)
  end

  def early_late_info(start)
    now = Time.now
    m = distance_of_time_in_words(now - start)
    m += (now > start) ? " ago" : " later"
  end

  def show_bar_links(name)
    javascript_tag("$('%s').down('.%s').show()" % [@curr_day, name])
  end

  def make_shift_link
    if @shift.has_sub_at_start?
      ''
    else
      if @shift.signed_in?
        link_to "Return to your shift report", :controller => "report",:action => "index"
      else
        confirm = (
          if @shift.too_early? #30 minutes early
            confirm = "Too early, this shift is #{early_late_info(@shift.start)}. Sign in anyway?"
          end)
        #if not too early, nil is returned by if

        link_to "Sign in to this shift report",{:controller => "report",
                                                :action => "create",
                                                :shift_id => @shift.id},
                                                {:method => :post,
                                                :confirm => confirm}
      end
    end
  end

  # moved/copied by Ahmet for template schedule to work with shift controller
  def split_items_by_days(list)
    a = [[], [], [], [], [], [], []]
    list.each { |e| a[e.wday] << e }
    a
  end

  def light_print_cell(type, from, to, object = nil, content = "")
    span = (to - from) / @dept_gran #DON'T HARD CODE GRANULARITY UGH! :P
    return '' if span==0
    content = object.user.name if object.class==ShiftTemplateItem
    "<td class='%s' colspan='%s'>%s</td>" % [type, span, content]
  end

end
