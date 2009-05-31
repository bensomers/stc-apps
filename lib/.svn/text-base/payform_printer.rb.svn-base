require 'pdf/writer'
require 'pdf/simpletable'

class PayformPrinter
  
  protected
  def self.print_payforms(admin_user, filename, payforms)
    pdf = PDF::Writer.new
    add_headers(pdf)
    pdf.margins_in(0.75, 0.5)
    email_body = ""
    first_page = true
    
    for payform in payforms
      if first_page
        first_page = false
      else
        pdf.start_new_page
      end
      payform.printed = Time.now
      if payform.save!
        email_body += print_to_pdf(payform, pdf)
      end
    end
    
    if email_body.blank?
      "No emails to send"
    else
      pdf.save_as("data/payforms/" + filename)
      email = PayformMailer.create_printed_payforms(admin_user,email_body, filename)
      PayformMailer.deliver(email)
      "Payforms printed."
    end
  end
  
  private
  def self.print_to_pdf(payform, pdf)
    #TODO: Change to the real employee ID later
    message  = "Name:         " + payform.user.name          + "\n"
    message += "Employee ID:  " + payform.user.ein.to_s       + "\n"  
    message += "NetID:        " + payform.user.login         + "\n"
    message += "Department:   " + payform.department.name    + "\n"
    message += "Week ending:  " + payform.get_date.to_s
    
    PDF::SimpleTable.new do |tab|
      tab.column_order.push(*%w(item value))
      tab.columns["item"] = PDF::SimpleTable::Column.new("item") { |col|
        col.heading       = "Item"
        col.justification = :left
      }
      tab.columns["value"] = PDF::SimpleTable::Column.new("value") { |col|
        col.heading       = "Value"
        col.justification = :left
      }
      tab.data = [
        { "item" => "<b>Name:</b>",        "value" => payform.user.name },
        { "item" => "<b>Employee ID:</b>", "value" => payform.user.ein.to_s },
        { "item" => "<b>NetID:</b>",       "value" => payform.user.login },
        { "item" => "<b>Department:</b>",  "value" => payform.department.name },
        { "item" => "<b>Week Ending:</b>", "value" => payform.get_date.to_s }
      ]
      tab.shade_rows    = :none
      tab.show_headings = false
      tab.show_lines    = :none
      tab.position      = :left
      tab.orientation   = :right
      tab.render_on(pdf)
    end
    
    # Print all active jobs in active categories
    for category in Category.active(payform.department)
      message += print_jobs(pdf, payform.payform_items.active.in_category(category.id), category.name)
    end
    
    # Print remaining active jobs in inactive categories
    message += print_jobs(pdf, payform.misc_jobs, "Other")

    
    total_hours = payform.total_hours
    message += "\n"*2 + "-"*60 + "\n" + " "*23 + "TOTAL HOURS: " + total_hours.to_s + "\n" + "-"*60 + "\n"*2
    message += "This payform was approved by " + User.find(payform.approved_by).name + payform.approved.strftime(" at %I:%M%p on %a %b %d, %Y\n\n")
    
    pdf.font_size = 14
    pdf.text "\n\n<b>TOTAL HOURS:</b> " + total_hours.to_s + "\n"*2, :justification => :center
    pdf.font_size = 10
    pdf.text "This payform was approved by " + User.find(payform.approved_by).name + payform.approved.strftime(" at %I:%M%p on %a %b %d, %Y\n\n"), :justification => :center
    
    message  # Returns a plain-text version of the pdf
  end
  
  private
  def self.print_jobs(pdf, payform_items, category_name)
    category_hours = 0
    job_msg = ""
    message = ""
    data = []

    for job in payform_items
      job_msg += "\n   " + job.date.to_s + "  " + job.description[0..20] 
      if job.description.length > 20
        job_msg += "..." + " "*3
      else
        job_msg += " "*(27-job.description.length)
      end
      job_msg += job.hours.to_s
      
      data << { "date" => job.date.to_s, "description" => job.description, "hours" => job.hours.to_s }
      category_hours += job.hours
    end
    # Do not print category if no payform_items exist in that category
    unless job_msg.blank?
      category_hours = category_hours
      message += "\n\n"
      message += category_name + " "*(50-category_name.length)
      message += category_hours.to_s + " hours"
      message += job_msg
    end
    unless data.empty?
      pdf.text "\n\n<b>" + category_name + "</b>"
      create_pdf_category_table(pdf, data)
      pdf.text "Category Hours:  " + category_hours.to_s, :justification => :right
    end
    
    message    
  end
  
  private
  def self.add_headers(pdf)
    pdf.open_object do |heading|
      pdf.save_state
      pdf.stroke_color! Color::RGB::Black
      pdf.stroke_style! PDF::Writer::StrokeStyle::DEFAULT
      s = 6
      t = "Payforms -- Printed on " + Date.today.strftime("%m/%d/%Y")
      w = pdf.text_width(t, s) / 2.0
      x = pdf.margin_x_middle
      y = pdf.absolute_top_margin
      pdf.add_text(x - w, y, t, s)
      x = pdf.absolute_left_margin
      w = pdf.absolute_right_margin
      y -= (pdf.font_height(s) * 1.01)
      pdf.line(x, y, w, y).stroke
      pdf.restore_state
      pdf.close_object
      pdf.add_object(heading, :all_pages)
    end
  end

  private
  def self.create_pdf_category_table(pdf, data)
     PDF::SimpleTable.new do |tab|
      tab.column_order.push(*%w(date description hours))
      tab.columns["date"] = PDF::SimpleTable::Column.new("date") { |col| 
        col.heading = "Date" 
      }
      tab.columns["description"] = PDF::SimpleTable::Column.new("description") { |col| 
        col.heading = "Description" 
        col.width   = 400
      }
      tab.columns["hours"] = PDF::SimpleTable::Column.new("hours") { |col| 
        col.heading       = "Hours"
        col.justification = :right
      }
    
      tab.show_lines       = :none
      tab.show_headings    = false
      tab.orientation      = :right
      tab.position         = :left
      tab.width            = 550
      tab.shade_color      = Color::RGB.from_html("#d6dfef")
      
      tab.data = data
      tab.render_on(pdf)
    end
  end  
  
end