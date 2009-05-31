module PayformAdminHelper

  def get_payforms(user_id, dept_id, status="all")
    payforms = Payform.all( :conditions => ["user_id = ? AND department_id = ?", user_id, dept_id] )
    payforms = payforms.collect { |p| p if p.get_status_text == status } unless status == "all"
    payforms.compact.sort! {|a,b| a.get_date <=> b.get_date}
  end
  
  #used to generate a link that will toggle an element on the page with that id
  def link_toggle(id, text)
    "<a href='#' onclick=\"Element.toggle('%s'); return false;\">%s</a>" % [id, text]    
  end
  
  def column_length(n)
    (@users.length/n).ceil
  end
  
  #TODO: Make number of columns specifiable (right now it is just 4)
  def default_num_columns
    @department.payform_configuration.add_jobs_cols == 0 ? 4 : @department.payform_configuration.add_jobs_cols
  end
  
  def num_columns(n)
    case @users.length
      when 0..n-1 then @users.length
      else n
    end
  end
  
  def mass_clock_clocks_users(models)
    users = []
    for model in models
      users << model.user
    end
    users
  end
  
  def mass_clock_payform_items_users(models)
    users = []
    for model in models
      users << model.payform.user
    end
    users
  end
end
