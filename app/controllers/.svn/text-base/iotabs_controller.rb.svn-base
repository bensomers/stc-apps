class IotabsController < ApplicationController
  before_filter CASACL::CASFilter
  
  # GET /iotabs
  # GET /iotabs.xml
  def index
    @user = get_user
    @iotabs = Iotab.find(:all, :conditions => {:user_id => @user}).sort_by {|t| t.food_item.name}
    @taken_before = @iotabs.map { |i| i.food_item }
    @food_items = (FoodItem.all_available - @taken_before).sort_by  {|f| f.name}
    uid = @user.id
    if request.post? && params[:food_item_ids]
      params[:food_item_ids].each do |fid|
        @iotab = Iotab.find_by_user_id_and_food_item_id(uid, fid) || Iotab.new(:user_id => uid, :food_item_id => fid, :paid => 0, :unpaid => 0)
        @iotab.unpaid += 1
        @iotab.save
      end
      redirect_with_flash "Updated successfully", :action => 'index'
    end    
  end

  def change
    @iotab = Iotab.find params[:id]
    c=params[:change].to_i
    case params[:way]
    when "Take"
      @iotab.unpaid += c
    when "Pay"
      @iotab.unpaid -= c
      @iotab.paid += c
    when "Return"
      @iotab.unpaid -= c
    else raise "Don't be naughty!"
    end
    
    if @iotab && @iotab.save
    else
      flash[:notice] = "Error Can't Update. Please report this bug"
    end
    
    @div_id = "iotab_row_#{@iotab.id}"
    respond_to do |wants|
      wants.html { redirect_to :action => 'index'  }
      wants.js
    end
    
  end
  
  def view_all #for Lori
    @user = get_user
    @iotabs = Iotab.all
  end
  
  def report_empty
    @food_item = Iotab.find(params[:id]).food_item
    msg = @food_item.available? ? "Marked #{@food_item.name} as unavailable" : "Item already reported as unavailable before. Please be patient."
    @food_item.available = false
    @food_item.save
    respond_to do |wants|
      wants.html { redirect_with_flash msg, :action => 'index' }
      wants.js { 
      render :update do |page|
        page['messages'].replace_html "<div id='notice'>#{msg}</div>"
      end
     }
    end
  end
  
  def destroy
    @iotab = Iotab.find(params[:id]).destroy
    @div_id = "iotab_row_#{@iotab.id}"
    msg = "Removed your tab of #{@iotab.food_item.name}"
    respond_to do |wants|
      wants.html { redirect_with_flash msg, :action => 'index' }
      wants.js {
        @iotabs = Iotab.find(:all, :conditions => {:user_id => get_user.id}).sort_by {|t| t.food_item.name}
        @taken_before = @iotabs.map { |i| i.food_item }
        @food_items = (FoodItem.all_available - @taken_before).sort_by  {|f| f.name}      
        render :update do |page|
          page.remove @div_id
          page['messages'].replace_html "<div id='notice'>#{msg}</div>"
          page['list_new'].replace_html :partial => 'new'
        end }
    end  
  end
end
