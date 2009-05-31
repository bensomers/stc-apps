class ShiftMailer < ActionMailer::Base
  

  def send_request(sub, url) #previously, I named this method 'request' and it caused a conflict!@#$ -H
    subject    'Sub Request: ' + sub.shift.short_display
    recipients sub.email_to   #email of those requestor put in offer_to or the sub mailing list (when blank)
    from       sub.user.email #email of sub requestor
    sent_on    Time.now
    
    body       :sub => sub, :url => url
  end

  def accept(sub, taker)#naming it accept also gave me problems
    sender = sub.shift.location.location_group.sub_email || ("email_NOT_yet_set_for_%" % location_group.short_name)
      
    subject    'Sub Accepted!'
    recipients sub.user.email #notify sub requestor of sub acceptance
    from       sender         #eg studtech-st-sub@mailman.yale.edu
    cc         taker.email    #cc to sub taker
    sent_on    Time.now
      
    body       :sub => sub, :taker => taker
  end

  def mail_report(shift_report)
    subject    'Shift Report: ' + shift_report.short_display
    recipients shift_report.shift.user.email
    if !shift_report.shift.location.report_email.blank?
      cc       shift_report.shift.location.report_email
    end
    from       shift_report.shift.user.email
    sent_on    Time.now
    
    body       :report => shift_report
  end
end
