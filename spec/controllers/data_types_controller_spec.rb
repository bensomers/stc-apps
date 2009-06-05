require File.dirname(__FILE__) + '/../spec_helper'
 
describe DataTypesController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => DataType.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    DataType.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    DataType.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(data_type_url(assigns[:data_type]))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => DataType.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    DataType.any_instance.stubs(:valid?).returns(false)
    put :update, :id => DataType.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    DataType.any_instance.stubs(:valid?).returns(true)
    put :update, :id => DataType.first
    response.should redirect_to(data_type_url(assigns[:data_type]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    data_type = DataType.first
    delete :destroy, :id => data_type
    response.should redirect_to(data_types_url)
    DataType.exists?(data_type.id).should be_false
  end
end
