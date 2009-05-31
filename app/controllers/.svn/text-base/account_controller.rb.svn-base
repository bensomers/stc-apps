require 'cas_acl'
# Move me to application.rb
class AccountController < ApplicationController
  # Check authentication with CAS login, but only on the login page
  before_filter CASACL::CASFilter, :only => [ :login ]
  
  #this allows us to use functions from form_helper.rb
  helper :form
  
  def logout
    reset_session
  end
  
  #I believe this method is never called and can be deleted - Adam
  def login
    redirect_to :controller => "/", :action => "index"
  end

end
