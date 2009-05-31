require File.dirname(__FILE__) + '/../test_helper'

class InterviewTest < Test::Unit::TestCase
  fixtures :interviews, :interview_questions

  def test_relationship
    # Find our example interview and make sure it's not nil
    eval = interviews(:spring)
    assert_not_nil eval
    
    # Make sure there are questions for the interview
    questions = eval.interview_questions
    assert !questions.empty?
    
    # Destroy interview
    assert eval.destroy
    
    # Make sure the questions are gone too
    assert InterviewQuestion.find(:all, :conditions => 'interview_id = 1').empty?
  end
end
