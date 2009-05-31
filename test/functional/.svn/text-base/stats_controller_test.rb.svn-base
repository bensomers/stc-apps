require 'test_helper'

class StatsControllerTest < ActionController::TestCase
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Stat.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Stat.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to stat_url(assigns(:stat))
  end
  
  def test_show
    get :show, :id => Stat.first
    assert_template 'show'
  end
end
