class PayformMailer < ActionMailer::Base
  #TODO: change recipients
  
  def reminder(admin_user, user, message)
    subject     'Payform Reminder'
    recipients  "#{user.name} <#{user.email}>"
    from        "#{admin_user.name} <#{admin_user.email}>"
    reply_to    "#{admin_user.name} <#{admin_user.email}>"
    sent_on     Time.now
    
    body        :user => user, :message => message
  end

  def warning(admin_user, user, message)
    subject     'Late Payforms Warning'
    recipients  "#{user.name} <#{user.email}>"
    from        "#{admin_user.name} <#{admin_user.email}>"
    reply_to    "#{admin_user.name} <#{admin_user.email}>"
    sent_on     Time.now
    
    body        :user => user, :message => message
  end
  
  def printed_payforms(admin_user, message, attachment_name)
    subject       'Printed Payforms ' + Date.today.strftime('%m/%d/%y')
    recipients    "#{admin_user.email}"
    from          'ST Payform Apps <studtech-st-dev-payform@mailman.yale.edu>'
    reply_to      'adam.bray@yale.edu'
    sent_on       Time.now
    content_type  'text/plain'
    
    body        :message => message
            
    attachment  :content_type => "application/pdf",
                :body         => File.read("data/payforms/" + attachment_name),
                :filename     => attachment_name
  end
  
  def admin_edit(payform, payform_item, edit_item)
    user = payform.user
    
    subject        'Your payform has been edited'
    recipients    "#{user.name} <#{user.email}>"
    from          'ST Payform Dev Team <studtech-st-dev-payform@mailman.yale.edu>'
    cc            User.find_by_login(edit_item.edited_by).email
    sent_on        Time.now
    content_type  'text/plain'
    
    body          :payform => payform, :payform_item => payform_item, :edit_item => edit_item
  end
  
end
