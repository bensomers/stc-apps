require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireTest < Test::Unit::TestCase
  fixtures :questionnaires, :questionnaire_questions

  def test_relationship
    # Find our example questionnaire and make sure it's not nil
    eval = questionnaires(:spring)
    assert_not_nil eval
    
    # Make sure there are questions for the questionnaire
    questions = eval.questionnaire_questions
    assert !questions.empty?
    
    # Destroy questionnaire
    assert eval.destroy
    
    # Make sure the questions are gone too
    assert QuestionnaireQuestion.find(:all, :conditions => 'questionnaire_id = 1').empty?
  end
end
