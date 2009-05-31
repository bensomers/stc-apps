class PayformTask
  
  def self.remind
    department = Department.find_by_name("STC")
    message = PayformConfiguration.find_by_department_id(department.id).reminder
    
    department.users.each do |user|
      PayformMailer.deliver(PayformMailer.create_reminder(user, message))
    end
  end
  
  def self.warn
    department = Department.find_by_name("STC")
    message = PayformConfiguration.find_by_department_id(department.id).reminder
    start_date = Date.parse(8.weeks.ago.strftime("%Y-%m-%d"))
    
    department.users.each do |user|
      Payform.find_or_create(Date.tomorrow.cweek, Date.tomorrow.at_beginning_of_week.year, user, department)
      unsubmitted_payforms = (Payform.all( :conditions => { :user_id => user.id, :department_id => department.id, :submitted => nil }, :order => 'year, week' ).collect { |p| p if p.get_date >= start_date }).compact
      
      unless unsubmitted_payforms.blank?
        weeklist = ""
        for payform in unsubmitted_payforms
          weeklist += payform.get_date.strftime("\t%b %d, %Y\n")
        end
        PayformMailer.deliever(PayformMailer.create_warning(user, message.gsub("@weeklist@", weeklist)))
      end
    end
  end
  
end
