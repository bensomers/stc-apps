class PayformAdmin::CategoriesController < PayformApplicationController
  before_filter :set_navbar
  
  def index
    @department = get_dept_from_url
    redirect_with_flash flash[:notice], :action => :view, :id => @department.id
  end
  
  def view
    @department = get_dept_from_url
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :view, :id => @department.id and return
    end
    @category = Category.new
  end
  
  def enable
    category = Category.find_by_id params[:id]
    if category && request.post?
      category.active = true
      if category.save
        redirect_with_flash "Category \'" + category.name + "\' Enabled", :action => :index, :id => category.department
      end
    else
    redirect_with_flash "Invalid Category", :action => :index
    end
  end
  
  def disable
    category = Category.find_by_id params[:id]
    if category && request.post?
      category.active = false
      if category.save
        redirect_with_flash "Category \'" + category.name + "\' Disabled", :action => :index, :id => category.department
      end
    else
    redirect_with_flash "Invalid Category", :action => :index
    end
  end
  
  def delete
    category = Category.find_by_id params[:id]
    if category && request.post?
      dept = category.department
      if category.destroy
        redirect_with_flash "Category \'" + category.name + "\' Deleted", :action => :index, :id => dept.id
      end
    else
    redirect_with_flash "Invalid Category", :action => :index
    end
  end
  
  def add
    department = get_dept_from_url
    if params[:category] && request.post?
      category = Category.new(params[:category])
      department.categories << category
      if category.save
        flash = "Category \'" + category.name + "\' Saved"
      else
        department.reload
      end
    end
    redirect_with_flash flash, :action => :index, :id => department.id
  end
  
  def controller_name
    PayformAdminController.controller_name
  end
  
  def set_navbar
    left_nav("payform_admin")
  end
  
end
