require "#{File.dirname(__FILE__)}/../test_helper"

class ApplyTest < ActionController::IntegrationTest
#  fixtures :applicants, :answers, :colleges, :users, :roles, :roles_users, :permissions, :permissions_roles

#  def test_redirects
#    u = new_session_as('studcomp')
#    u.get_index
#    u.apply_basic
#    #u.redirect_to_basic
#    #u.complete_basic
#    #u.redirect_to_questionnaire
#    #u.complete_questionnaire
#    #u.redirect_to_evaluation
#  end
#  
#  def test_apply
#    u = new_session_as('studcomp')
#    u.get_index
#    u.apply_basic
#  end
#  
#  private
#  
#  module CustomAssertions
#    def login_as(user, controller)
#      CASACL::CASFilter.login_as(user, controller)
#    end
#    
#    def get_index
#      get "/"
#      assert_response :redirect
#    end
#    
#    def apply_basic
#      get "/apply/basic"
#      assert_response :redirect
#    end
#    
#    def complete_basic
#      post "/apply/basic", :applicant => { :nickname => '',
#                                           :college => 'Other',
#                                           :netid => 'studcomp',
#                                           :year => 2007,
#                                           :first_name => 'Stud',
#                                           :last_name => 'Comp',
#                                           :email => 'studcomp@yale.edu' }
#      assert_redirected_to "/apply/questionnaire"
#    end
#    
#    def redirect_to_basic
#      get "/apply/questionnaire"
#      assert_redirected_to "/apply/basic"
#      
#      get "/apply/evaluation"
#      assert_redirected_to "/apply/basic"
#    end
#    
#    def redirect_to_questionnaire
#      get "/apply/basic"
#      assert_redirected_to "/apply/questionnaire"
#      
#      get "/apply/evaluation"
#      assert_redirected_to "/apply/questionnaire"
#    end
#    
#    def redirect_to_evaluation
#      get "/apply/basic"
#      assert_redirected_to "/apply/evaluation"
#      
#      get "/apply/questionnaire"
#      assert_redirected_to "/apply/evaluation"
#    end
#  end
#  
#  def new_session_as(user)
#    open_session do |u|
#      u.extend(CustomAssertions)
#      u.get "/account/login"
#      u.login_as(user, u.controller)
#      yield u if block_given?
#    end
#  end
end
