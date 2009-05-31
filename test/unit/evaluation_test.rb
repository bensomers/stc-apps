require File.dirname(__FILE__) + '/../test_helper'

class EvaluationTest < Test::Unit::TestCase
  fixtures :evaluations, :evaluation_questions

  def test_relationship
    # Find our example evaluation and make sure it's not nil
    eval = evaluations(:spring)
    assert_not_nil eval
    
    # Make sure there are questions for the evaluation
    questions = eval.evaluation_questions
    assert !questions.empty?
    
    # Destroy evaluation
    assert eval.destroy
    
    # Make sure the questions are gone too
    assert EvaluationQuestion.find(:all, :conditions => 'evaluation_id = 1').empty?
  end
end
