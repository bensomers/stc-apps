class Preference < ActiveRecord::Base
  belongs_to :user
  
  # def hide_all_bars?
  #   hide_bars == 'all'
  # end
  
  # def hide_all_bars
    #   hide_bars = 'all'
  # end
  
  def hidden_groups
    (hide_location_groups||'').split(',')
  end
  
  def set_hidden_groups(list)
    self.hide_location_groups = list.join(',')
  end
  
  def hide_group?(lg)    
    hidden_groups.include? lg.id.to_s
  end
  
  # def update_hidden_groups(id_list)
    #   self.hide_location_groups = (hidden_groups - id_list).join(',')
    # end
    
end
