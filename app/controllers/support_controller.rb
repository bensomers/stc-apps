class SupportController < ApplicationController
  def index
    @dept = Department.find_by_name(params[:dept].gsub(/_/,' ')) || (raise "Department name #{params[:dept]} not found")
    @locations = @dept.location_groups.collect { |lg| lg.locations }.flatten
    loc_name = params[:loc].gsub(/_/,' ').downcase
    @location = @locations.select { |loc| loc.short_name.downcase==loc_name }.first ||
                (raise "Location name #{params[:loc]} not found")
  rescue Exception => e
    if @dept and @locations
      render :action => 'choose_location'
    else
      redirect_with_flash e.message, root_path
    end
  else
    sc = @dept.shift_configuration
    @dept_start_hour = sc.start / 60
    @dept_end_hour = sc.end / 60
    @dept_gran = sc.granularity

    @blocks_per_day = (sc.end - sc.start) / @dept_gran
    @blocks_per_hour = 60 / @dept_gran

    week_date = params[:date].blank? ? Date.today : Date.parse(params[:date])
    @week_days = get_week week_date

    @start_minutes = sc.start.minutes
    @end_minutes = sc.end.minutes

    @no_layout = params[:plain]
  end


end
