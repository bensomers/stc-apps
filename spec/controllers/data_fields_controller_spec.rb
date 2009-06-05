require File.dirname(__FILE__) + '/../spec_helper'
 
describe DataFieldsController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => DataField.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    DataField.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    DataField.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(data_field_url(assigns[:data_field]))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => DataField.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    DataField.any_instance.stubs(:valid?).returns(false)
    put :update, :id => DataField.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    DataField.any_instance.stubs(:valid?).returns(true)
    put :update, :id => DataField.first
    response.should redirect_to(data_field_url(assigns[:data_field]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    data_field = DataField.first
    delete :destroy, :id => data_field
    response.should redirect_to(data_fields_url)
    DataField.exists?(data_field.id).should be_false
  end
end
