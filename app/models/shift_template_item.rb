class ShiftTemplateItem < TemplateItem
  belongs_to :user

  validate :user_validation
  
  def user_name
    return nil unless self.user
    self.user.name
  end
  
  def user_name=(u_n)
    @name = u_n #kept for validation
    self.user = User.find_by_name(u_n)
    
  end
  
  def apply_to_date(date)
    if date.wday == self.wday
      shifthash = {}
      shifthash[:start] = date + self.start.minutes
      shifthash[:end] = date + self.end.minutes
      shifthash[:location_id] = self.location_id
      shifthash[:user_id] = self.user_id
      shifthash
    else
      nil
    end
  end

  def user_validation
    unless user
      if @name and not @name.blank?
        errors.add_to_base("user name not found!")
      else
        errors.add_on_blank(:user)
      end
    end
  end
end
