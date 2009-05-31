class LineItem < ActiveRecord::Base
  belongs_to :shift_report
  
  validates_presence_of :line_content
  def line_content_with_formatting
    line_content.sanitize_and_format
  end
end
