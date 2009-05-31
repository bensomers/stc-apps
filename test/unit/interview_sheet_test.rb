require File.dirname(__FILE__) + '/../test_helper'

class InterviewSheetTest < Test::Unit::TestCase
#  include ValidationTestHelper
  
#  fixtures :interview_sheets, :interviews, :applicants
#
#  def test_relationship
#    # Find our example sheet and make sure it's not nil
#    sheet = interview_sheets(:first)
#    assert_not_nil sheet
#    
#    # Make sure applicant, interview exist
#    applicant = Applicant.find(sheet.applicant_id)
#    assert_not_nil applicant
#    
#    interview = Interview.find(sheet.interview_id)
#    assert_not_nil interview
#  end
#  
#  def test_validations
#    @model = InterviewSheet.new(:interview_id => 1,
#                                :applicant_id => 1,
#                                :interviewer => 'dwh24')
#    
#    # Check field presence
#    [:interview_id, :applicant_id, :interviewer].each do |field|
#      assert_invalid field, 'can\'t be blank', nil
#    end
#    
#    # Check presence of foreign key objects
#    [:interview_id, :applicant_id].each do |field|
#      assert_invalid field, 'does not exist', 100
#    end
#    
#    # Check proper save
#    assert @model.save
#  end
end
