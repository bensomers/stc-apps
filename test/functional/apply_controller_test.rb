require File.dirname(__FILE__) + '/../test_helper'
require 'apply_controller'

# Re-raise errors caught by the controller.
class ApplyController; def rescue_action(e) raise e end; end

class ApplyControllerTest < Test::Unit::TestCase
  def setup
    @controller = ApplyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
