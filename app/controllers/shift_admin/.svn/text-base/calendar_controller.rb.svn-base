require 'icalendar'
require 'date'

class ShiftAdmin::CalendarController < ShiftAdminController

  include Icalendar

  def controller_name
    ShiftAdminController.controller_name
  end

  def index
    @user = get_user
    @department = get_department
    @location_groups = @department.location_groups.select { |lg| lg.allow_view? @user }
    @locations = @location_groups.map { |group| group.locations }.flatten!

    if request.post?
      @start_date = params[:start_date_select]
      @end_date = params[:end_date_select]
      @shifts = Shift.all_between(@start_date, @end_date).filter_by_department(@department)
      cal = Calendar.new
      @shifts.each do |shift|
        cal.event do
          dtstart     shift.start.to_datetime
          dtend       shift.end.to_datetime
          summary     "#{shift.user.name} @ #{shift.location.long_name}"
        end
      end

      cal_string = cal.to_ical
      filename = Time.now.strftime("calendar_%Y%m%d%H%M%S.ics")
      File.open(filename, 'w') {|f| f.write(cal_string) }
      send_file(filename)
  
    end
    
  end

end
