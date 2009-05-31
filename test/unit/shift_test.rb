require 'test/test_helper'

class ShiftTest < ActiveSupport::TestCase
  fixtures :shifts, :users
 # Replace this with your real tests.
  def test_truth
   assert true
  end
  
  def test_front_joining
    early = shifts(:shift_one)
    s = Shift.make :start => Time.parse('2009-08-17 03:00:00'), :end => Time.parse('2009-08-17 03:30:00'), :user_id => 9, :location_id => 1
    assert_equal s.start, Time.parse('2009-08-17 02:00:00')
 end
  def test_back_joining
    later = shifts(:shift_five)
    s = Shift.make :start => Time.parse('2009-08-17 04:00:00'), :end => Time.parse('2009-08-17 05:00:00'), :user_id => 9, :location_id => 1
    assert_equal s.end, Time.parse('2009-08-17 06:00:00')
  end
  def test_both_joining
    early = shifts :shift_one
    later = shifts :shift_five    
    s = Shift.make :start => Time.parse('2009-08-17 03:00:00'), :end => Time.parse('2009-08-17 05:00:00'), :user_id => 9, :location_id => 1
    assert_equal s.start, Time.parse('2009-08-17 02:00:00')
    assert_equal s.end, Time.parse('2009-08-17 06:00:00')
  end
  def test_join_rollback
    # early = shifts :shift_one
    later = shifts :shift_five    
    s = Shift.make :start => Time.parse('2009-08-17 01:00:00'), :end => Time.parse('2009-08-17 05:00:00'), :user_id => 9, :location_id => 1
    assert !s.valid?
  end
  
  def test_duration_validation
    #create a long shift --> validation should fail
    
    #then make it shorter --> can be sign up
    
    #joining long shift --> error
    
    #sign up for a long shift but have admin bypass
  end
end