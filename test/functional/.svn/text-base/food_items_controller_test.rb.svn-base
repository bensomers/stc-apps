require 'test_helper'

class FoodItemsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:food_items)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_food_item
    assert_difference('FoodItem.count') do
      post :create, :food_item => { }
    end

    assert_redirected_to food_item_path(assigns(:food_item))
  end

  def test_should_show_food_item
    get :show, :id => food_items(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => food_items(:one).id
    assert_response :success
  end

  def test_should_update_food_item
    put :update, :id => food_items(:one).id, :food_item => { }
    assert_redirected_to food_item_path(assigns(:food_item))
  end

  def test_should_destroy_food_item
    assert_difference('FoodItem.count', -1) do
      delete :destroy, :id => food_items(:one).id
    end

    assert_redirected_to food_items_path
  end
end
