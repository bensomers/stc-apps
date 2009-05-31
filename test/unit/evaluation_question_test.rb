require File.dirname(__FILE__) + '/../test_helper'

class EvaluationQuestionTest < Test::Unit::TestCase
  fixtures :question_types, :evaluations
  
  def test_parent_exists
    # Create a question for an evaluation that doesn't exist
    question = EvaluationQuestion.new(:question => "What is your favorite color?",
                                      :evaluation_id => 3)
    assert !question.save
  end
  
  # Make sure we require choices for the appropriate question types
  def test_check_choices
    # Make sure a pulldown requires choices
    question = EvaluationQuestion.new(:question => "Select an OS with multithreading",
                                      :question_type_id => "5",
                                      :evaluation_id => 2)
    assert !question.save
    question = EvaluationQuestion.new(:question => "Select an OS with multithreading",
                                      :question_type_id => "5",
                                      :choices => "Unix\nWindows 3.1\nMac OS 6",
                                      :evaluation_id => 2)
    assert question.save
    
    # Make sure a text_box doesn't require them
    question = EvaluationQuestion.new(:question => "Describe multithreading",
                                      :question_type_id => "2",
                                      :evaluation_id => 2)
    assert question.save
  end
end
