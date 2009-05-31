require File.dirname(__FILE__) + '/../test_helper'

class ApplicantTest < Test::Unit::TestCase
  fixtures :applicants

  def test_crud
    # Create a new user
    new_user = Applicant.new( :netid => "mnv5",
                              :college => "TD",
                              :first_name => "Minh",
                              :last_name => "Vuong",
                              :year => "2002",
                              :email => "minh.vuong@yale.edu" )
    assert new_user.save
    
    # Read the user
    validation = Applicant.find(new_user.id)
    
    # Make sure original is preserved
    assert_equal(new_user.netid, validation.netid)
    
    # Make a change
    validation.first_name = "Minh"
    assert validation.save
    
    # Destroy
    assert validation.destroy
    
    # Make sure it's gone
    validation = Applicant.find(:first, :conditions => [ "id = ?", new_user.id ])
    assert_nil validation
  end
  
  def test_validations
    # Create user missing netid
    new_user = Applicant.new()
    assert !new_user.valid? # Make sure it's not valid
    assert !new_user.save # Make sure it doesn't save
    
    # Fix the problem
    new_user.netid = "dwh24"
    new_user.college = "JE"
    new_user.first_name = "Daniel"
    new_user.last_name = "Holevoet"
    new_user.year = 2007
    new_user.email = "daniel.holevoet@yale.edu"
    assert new_user.save # Make sure it works now
  end
end
