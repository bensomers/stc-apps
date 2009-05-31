require File.dirname(__FILE__) + '/../test_helper'

class CollegeTest < Test::Unit::TestCase
  fixtures :colleges

  # Do a simple read check, since that is all we do
  def test_read
    je = College.find(:first, :conditions => "abbrev = 'JE'")
    assert_equal(je.college, "Jonathan Edwards")
  end
end
