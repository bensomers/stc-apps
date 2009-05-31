require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireQuestionTest < Test::Unit::TestCase
  fixtures :question_types, :questionnaires
  
  def test_parent_exists
    # Create a question for an questionnaire that doesn't exist
    question = QuestionnaireQuestion.new(:question => "What is your favorite color?",
                                     :questionnaire_id => 3)
    assert !question.save
  end
  
  # Make sure we require choices for the appropriate question types
  def test_check_choices
    # Make sure a pulldown requires choices
    question = QuestionnaireQuestion.new(:question => "Have you repaired any of the following?",
                                     :question_type_id => "3",
                                     :questionnaire_id => 1)
    assert !question.save
    question = QuestionnaireQuestion.new(:question => "Have you repaired any of the following?",
                                     :question_type_id => "3",
                                     :choices => "Laptop\nDesktop\nPrinter\nRouter",
                                     :questionnaire_id => 1)
    assert question.save
    
    # Make sure a text_box doesn't require them
    question = QuestionnaireQuestion.new(:question => "Describe yourself",
                                     :question_type_id => "2",
                                     :questionnaire_id => 1)
    assert question.save
  end
end
