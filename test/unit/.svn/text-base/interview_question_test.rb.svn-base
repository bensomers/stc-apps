require File.dirname(__FILE__) + '/../test_helper'

class InterviewQuestionTest < Test::Unit::TestCase
  fixtures :question_types, :interviews
  
  def test_parent_exists
    # Create a question for an interview that doesn't exist
    question = InterviewQuestion.new(:question => "What is your favorite color?",
                                     :interview_id => 3)
    assert !question.save
  end
  
  # Make sure we require choices for the appropriate question types
  def test_check_choices
    # Make sure a pulldown requires choices
    question = InterviewQuestion.new(:question => "Have you repaired any of the following?",
                                     :question_type_id => "3",
                                     :interview_id => 1)
    assert !question.save
    question = InterviewQuestion.new(:question => "Have you repaired any of the following?",
                                     :question_type_id => "3",
                                     :choices => "Laptop\nDesktop\nPrinter\nRouter",
                                     :interview_id => 1)
    assert question.save
    
    # Make sure a text_box doesn't require them
    question = InterviewQuestion.new(:question => "Describe yourself",
                                     :question_type_id => "2",
                                     :interview_id => 1)
    assert question.save
  end
end
