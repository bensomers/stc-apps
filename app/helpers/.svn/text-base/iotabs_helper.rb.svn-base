module IotabsHelper
  def link_to_add_remove(link, c,iotab_id)
    link_to_remote link, :url => {:action => 'change', :change => c, :way => link, :id => iotab_id}, :class => "tab_change"
  end
end
