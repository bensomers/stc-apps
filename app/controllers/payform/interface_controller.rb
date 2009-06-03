#-------------------------------------
# RT INTERFACE CONTROLLER
# for use with RT
# potential use with other custom apps
#
# Written by Nathan, modified by Harley. Please talk Harley before making changes below
#-------------------------------------

class Payform::InterfaceController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :except => :add_job
  def add_job
    session[:add_to_payform] = params.clone
    session[:add_to_payform][:ip] = request.remote_ip
    redirect_to :action => :add_job_after
  end
  
  def add_job_after
    if (p = session[:add_to_payform])
      user = get_user
      unless user.login==p[:netid]#if currently logged in user of RT and Payform are different
        if p[:netid] and (rt_user = User.find_by_login(p[:netid]))#if RT is actually sending netid
          flash[:big_notice] = "ALERT: Payform cannot bill for #{rt_user.full_name}, because #{user.full_name} is still logged in here. Please log #{user.full_name} out of Payform and try billing again from RT."
          redirect_to :controller => '/index' and return
        else
          redirect_with_flash "Please contact Admin if this happens. ERROR CODE 1DITED", :controller => '/index'
          return
        end
      end
        
      #temporary view related test stuff:
      # @ip = p[:ip]
      # @url1 = p[:url] || "none"
      # @date1 = p[:date] || "none"
      # @category1 = p[:category] || "none"
      # @total1 = p[:total] || "none"
      # @comments1 = p[:comments] || "none"
      
      #if request.remote_ip == <IP ADDRESS????>
        if p[:total] and p[:comments] and p[:date]
          week = Date.tomorrow.cweek
          year = Date.tomorrow.at_beginning_of_week.year
          department = Department.find_by_name("STC")#only bill to STC
          if department.nil?
            redirect_with_flash "Department STC not found", :controller => '/index'
            return
          end
          
          current_payform = Payform.find_or_create(week, year, user, department) 
          
          payform_item = PayformItem.new(
            :hours       => p[:total].to_f,
            :description => p[:comments],
            :added_by    => "RT",
            :department_id => department.id) 
          payform_item.date = Date.parse(p[:date])
          current_payform.payform_items << payform_item
          
          payform_item.save!
          if p[:url]
            redirect_to p[:url] and return
          end
        end
      #else
      #flash[:notice] = "Your netid and ip address have been reported. Please stop playing with the urls."
      #end
      #redirect_to :controller => "/index"
    else
      redirect_with_flash "Please contact Admin if this happens. ERROR CODE 2NOISSES", :controller => '/index'
    end      
  end
  
  # def addJob #for use with the old URL
    #   redirect_to :action => 'add_job',
    #               :url => session[:add_to_payform][:url],
    #               :date => session[:add_to_payform][:date],
    #               :category => session[:add_to_payform][:category],
    #               :total => session[:add_to_payform][:total],
    #               :comments => session[:add_to_payform][:comments]
    # end
    
  #def add_old
  #  @ip = request.remote_ip  
  #  @url = session[:add_to_payform][:url]
  #  @date = session[:add_to_payform][:date]
  #  @category = session[:add_to_payform][:category]
  #  @total = session[:add_to_payform][:total]
  #  @comments = session[:add_to_payform][:comments]
  #  flash[:notice] = flash[:notice]
  #  redirect_to "http://caweb.wss.yale.edu/payform/interface/addJob",
  #              :url => @url,
  #              :date => @date,
  #              :category => @category,
  #              :total => @total,
  #              :comments => @comments
  #end
  
  # def controller_name
  #   PayformController.controller_name
  # end
  
  # def index
          #   redirect_to :action => "add_job"
          # end
                
            
  def chooser_options
    { "choices" => get_departments,
      "required" => true }
  end
end
