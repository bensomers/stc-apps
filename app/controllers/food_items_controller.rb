class FoodItemsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  layout "iotabs"
  # GET /food_items
  # GET /food_items.xml
  def index
    @food_items = FoodItem.find(:all)
    @food_item = FoodItem.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @food_items }
    end
  end

  # GET /food_items/1
  # GET /food_items/1.xml
  def show
    @food_item = FoodItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @food_item }
    end
  end

  # GET /food_items/1/edit
  def edit
    @food_item = FoodItem.find(params[:id])
  end

  # POST /food_items
  # POST /food_items.xml
  def create
    @food_item = FoodItem.new(params[:food_item])

    respond_to do |format|
      if @food_item.save

        format.html {
          flash[:notice] = 'FoodItem was successfully created.'
          redirect_to(@food_item) }
        format.xml  { render :xml => @food_item, :status => :created, :location => @food_item }
        format.js {
          render :update do |page|
            page.insert_html :bottom, 'food_item_table', :partial => @food_item
            page.visual_effect :highlight, "food_item_row_#{@food_item.id}"
            page.replace_html 'food_item_error', ''
            page.replace_html 'messages', "<div id='notice'>Added #{@food_item.name}.</div>"
            page << 'document.forms[0].reset()'
          end
        }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @food_item.errors, :status => :unprocessable_entity }
        format.js {
          render :update do |page|
            page.replace_html 'food_item_error', error_messages_for('food_item')
          end
        }
      end

    end
  end

  # PUT /food_items/1
  # PUT /food_items/1.xml
  def update
    @food_item = FoodItem.find(params[:id])

    respond_to do |format|
      if @food_item.update_attributes(params[:food_item])
        flash[:notice] = 'FoodItem was successfully updated.'
        format.html { redirect_to(@food_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @food_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /food_items/1
  # DELETE /food_items/1.xml
  def destroy
    @food_item = FoodItem.find(params[:id])
    @food_item.destroy

    respond_to do |format|
      format.html { redirect_to(food_items_url) }
      format.xml  { head :ok }
    end
  end
end
