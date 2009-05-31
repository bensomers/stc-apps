module ClockHelper
  def get_button_if_time
    (@clock.running) ? button_to( "Stop Clock", :controller => "/clock/out" ) : (@clock.out ? button_to( "Start Clock",  :controller => "/clock/restart") : ' ')
  end
end
