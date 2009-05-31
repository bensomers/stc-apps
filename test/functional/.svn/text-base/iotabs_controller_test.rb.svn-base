require 'test_helper'

class IotabsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:iotabs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_iotab
    assert_difference('Iotab.count') do
      post :create, :iotab => { }
    end

    assert_redirected_to iotab_path(assigns(:iotab))
  end

  def test_should_show_iotab
    get :show, :id => iotabs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => iotabs(:one).id
    assert_response :success
  end

  def test_should_update_iotab
    put :update, :id => iotabs(:one).id, :iotab => { }
    assert_redirected_to iotab_path(assigns(:iotab))
  end

  def test_should_destroy_iotab
    assert_difference('Iotab.count', -1) do
      delete :destroy, :id => iotabs(:one).id
    end

    assert_redirected_to iotabs_path
  end
end
