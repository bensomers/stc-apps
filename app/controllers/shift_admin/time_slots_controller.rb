class ShiftAdmin::TimeSlotsController < ShiftAdminController
  before_filter :fetch_schedule_view_variables
  def controller_name
    ShiftAdminController.controller_name
  end
  
  def index
    week_date = params[:date].blank? ? Date.today : Date.parse(params[:date])
    @week_days = get_week week_date
    
    @time_choices_select = get_department.shift_configuration.minute_blocks.map{|m| [m.min_to_am_pm, m]}

    @loc_groups_all = fetch_location_groups
    @loc_groups = pref_filter(@loc_groups_all)
    @locations = @loc_groups.collect(&:locations).flatten

    wdays = (params[:days] || []).map { |day| day.to_i }

    if request.post? and (params[:time_slots] || params[:new_slot])
      if params[:new_slot]
        start_time = params[:new_slot][:start_in_minute].to_i.minutes
        end_time = params[:new_slot][:end_in_minute].to_i.minutes
      end
      
      error_list = []
      (params[:location_ids] || []).each do |id|
        wdays.each do |day|
          #need @time_slot here to store error messages
          slot = TimeSlot.create(:location_id => id, :start => @week_days[day] + start_time , :end => @week_days[day] + end_time)
          error_list << slot.errors.full_messages
        end
      end

      (params[:time_slots] || {}).keys.each do |slot_id|
        slot = TimeSlot.find(slot_id) #need this because we need slot.date
        slot.update_attributes params[:time_slots][slot_id]
        slot.destroy if (params[:delete_ids]||[]).include?(slot_id) and slot.date >= Date.today
        error_list << slot.errors.full_messages

      end
      a = error_list.flatten.to_sentence
      flash[:notice] = a.blank? ? 'successfully updated.' : a
      redirect_to :action => 'index', :date => params[:date]
    end
  end
end
