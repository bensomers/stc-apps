require File.dirname(__FILE__) + '/../test_helper'
require 'applicants_controller'

# Re-raise errors caught by the controller.
class ApplicantsController; def rescue_action(e) raise e end; end

class ApplicantsControllerTest < Test::Unit::TestCase
  fixtures :applicants, :colleges

  def setup
    @controller = ApplicantsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :redirect
  end
end
