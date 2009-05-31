class EditItem < ActiveRecord::Base
  belongs_to :payform_item
  belongs_to :category

  validates_presence_of :date, :payform_item_id, :category_id
  
  def validate
      errors.add(:reason, "seems too short") if reason.length < payform_item.department.payform_configuration.reason_min if reason
  end
  
  def self.new_item(payform_item)
    edit_item = EditItem.new
  edit_item.payform_item_id = payform_item.id; #assign it the proper id
  edit_item.hours = payform_item.hours
  edit_item.date = payform_item.date
  edit_item.description = payform_item.description
  edit_item.category_id = payform_item.category_id   
  edit_item  
  end
  
end
