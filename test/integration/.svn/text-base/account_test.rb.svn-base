require "#{File.dirname(__FILE__)}/../test_helper"

class AccountTest < ActionController::IntegrationTest
  # fixtures :applicants, :answers, :colleges, :users, :roles, :roles_users, :permissions, :permissions_roles

#  def test_logout
#    #user = user_for_test
#    #user.login
#    #user.get_admin
#    # Open our session
#    open_session do |u|
#      u.extend(TestingDSL)
#      
#      # Setup a controller
#      u.get "/account/login"
#      assert :redirect
#      
#      # Perform pseudo-login
#      u.login_as('dwh24', u.controller)
#      assert_not_nil u.controller.session[:user]
#      assert_equal u.controller.session[:user], User.find(:first, :conditions => "login = 'dwh24'")
#      assert u.controller.session[:expires] > Time.now
#      #assert u.controller.session[:user].role_authorized?("superuser")
#      #assert_block(u.controller.session[:user].permission_strings.join) do false end
#      #assert_block(u.controller.session.inspect) do false end
#      
#      u.get "/admin/main", { :user => u.controller.session[:user], :expires => Time.now + 3600}
#      #u.assert_redirected_to "/"
#      
#      # Perform logout request
#      u.get "/account/logout"
#      
#      # Make sure we killed the session
#      assert_nil u.controller.session[:user]
#    end
#  end
#  
#  def user_for_test
#    open_session do |user|
#      def login
#        assert_nil session[:user]
#        session[:user] = users(:first)
#        session[:expires] = Time.now + 3600
#        assert_not_nil session[:user]
#      end
#      def get_admin
#        get "/admin/main"
#        assert_response :success
#      end
#    end
#  end
#  
#  private
#  
#  module TestingDSL
#    def login_as(user, controller)
#      CASACL::CASFilter.login_as(user, controller)
#    end
#  end
end
