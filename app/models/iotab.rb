class Iotab < ActiveRecord::Base
  belongs_to :user
  belongs_to :food_item
  validates_presence_of :user_id, :food_item_id
  validates_numericality_of :paid, :unpaid

  def paid_amt
    food_item.price * paid  
  end  
  
  def unpaid_amt
    food_item.price * unpaid
  end
  
end
