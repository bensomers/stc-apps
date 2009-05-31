class UsersController < ApplicationController

  def select_user
    if params[:all_in_dept]
      @selected_users = Department.find(params[:all_in_dept]).users
    else
      @selected_users = User.get_selected(params)
    end
    @department = Department.find_by_id(params[:department]) || get_department
    
    if request.xhr?
      begin
        if params[:selected_user]
          su = @department.users.search(params[:selected_user][:name]).first if params[:selected_user][:name]
          if @selected_users.include?(su) #this way we prevent seleceted duplicates
            notice = 'already selected'
          else
            @selected_users << su
          end
        end
                
        render :update do |page|
          update_user_select_and_hidden_ids_field page
          page << 'Form.reset("user_form_ajax");'
          if notice
            page.replace_html 'search_errors', notice
            page['search_errors'].show
            page['search_errors'].visual_effect :fade, :duration => 2.5
          end
        end
      rescue Exception => e
        # y e.message
        render :update do |page|
          page << 'Form.reset("user_form_ajax");'
          page.replace_html 'search_errors', 'NOT FOUND' #Nathan, don't change it back to e.message -H
          page['search_errors'].show
          page['search_errors'].visual_effect :fade, :duration => 2.5
        end
      end
    end
  end
  
  #TODO: i think get_department is useless here because there's no chooser before filter -H
  #for now the safe way is to include id of department in form
  def live_search
    dept = Department.find_by_id(params[:id]) rescue get_department
    @users = dept.users.search(params[:search])
  end
  
  
  def deselect_user    
    if params[:none]
      @selected_users = []
    else
      ids = params[:selected_ids].split(',') - [params[:deselect_id]]
      @selected_users = User.find(ids) rescue []
    end
    
    if request.xhr?
      render :update do |page|
        update_user_select_and_hidden_ids_field page
      end
    end
  end
  
  def add_users_in_group
    if request.xhr? and params[:group]
      @selected_users = User.get_selected(params) | Group.find_by_name(params[:group][:name]).users
      render :update do |page|
        update_user_select_and_hidden_ids_field page
      end
    end
  end
  

  private

end
