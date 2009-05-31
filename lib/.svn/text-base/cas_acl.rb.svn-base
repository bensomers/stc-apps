require 'net/https'
require 'rexml/document'

# require 'rubygems'
# gem 'actionpack'

# We must override redirect_to in ActionController::Base to allow this class to
# redirect the user to the CAS server for login.
class ActionController::Base; public :redirect_to; public :render; end
  
# We must also override reset_session in ActionController::Base to allow us to
# reset our sessions outside of the controller
class ActionController::Base; public :reset_session; end

# Provides services to login to CAS and validate the user's netid against an ACL system
module CASACL
  # The URL of the server to authenticate against.
  CAS_SERVER_URL = 'secure.its.yale.edu' unless CASACL.const_defined? "CAS_SERVER_URL"

  # The port the CAS server is running on.
  PORT = 443 unless CASACL.const_defined? "PORT"
  
  # Session Timeout in seconds
  TIMEOUT = 3 unless CASACL.const_defined? "TIMEOUT" # 3 hours

  class CASFilter
    # Returns a boolean: did user successfully authenticate?
    def self.filter(controller)

      # If we have a user, a successful login was made for this session
      if (controller.session[:user] && controller.session[:expires] > Time.now)
        controller.session[:expires] = TIMEOUT.hours.from_now # Reset session timeout due to activity
        return CASACL.login_required(controller)
      else
        temp = controller.session[:add_to_payform]
        controller.reset_session
        controller.session[:add_to_payform] = temp
      end
      
      # Otherwise, we require a ticket to authenticate the user
      # This is the fix to maintain GET query params after redirect
      # delete ticket from redirect_params is impt because the CAS ticket is invalid -H
      redirect_params = controller.params.clone
      redirect_params.delete :ticket
      service = controller.url_for(redirect_params)
      
      ticket = controller.params[:ticket]
      
      if ticket.blank?
        #Adding the following code to deal with ajaxing after session has expired -H
        if controller.request.xhr?
          controller.render :update do |page|
            page.alert "CAS session expired. Redirecting to CAS server... Please re-enter your request after that."
            page << "window.location.reload();"
          end
          return false
        end#end of added code
        
        print "Redirecting to CAS server...\n"
        controller.redirect_to "https://#{CAS_SERVER_URL}/cas/login?service=#{service}"
        return false
      end
      
      cas_payload = validate_ticket(service, ticket)
      return false if cas_payload.nil?
      
      controller.session[:user] = cas_payload.first
      controller.session[:expires] = TIMEOUT.hours.from_now # Initialize session timeout
      
      user = User.find(:first, :conditions => ['login = ?', cas_payload.first])
      
      if user
        controller.session[:user_exists] = true
      else
        controller.session[:user_exists] = false
      end
      
      # Make sure we have the appropriate permissions
      if CASACL.login_required(controller)
        return true
      end
      return false
    end
    
    private

    # Validates a CAS ticket with the server.
    #
    # Inputs:
    # [service] The URL of the calling service.
    # [ticket] The CAS ticket returned by the server in the URL.
    #
    # Returns an array: [ NetID, UIN ]
    def self.validate_ticket(service, ticket)
      #print "Validating service with CAS...\n"
      http = Net::HTTP.new(CAS_SERVER_URL, PORT)
      http.use_ssl = true
      page = http.get("/cas/serviceValidate?service=#{service}&ticket=#{ticket}").body

      # Parse XML document returned by CAS server
      doc = REXML::Document.new(page)
      # Print XML document for troubleshooting
      #print doc
      return unless REXML::XPath.first(doc, 'cas:serviceResponse/cas:authenticationFailure',
        'cas:serviceResponse' => 'http://www.yale.edu/tp/cas').nil?
      return if REXML::XPath.first(doc, 'cas:serviceResponse/cas:authenticationSuccess').nil?

      # Parse text values for NetID
      #print "Parsing text value for NetID...\n"
      cas_payload = Array.new
      cas_payload << REXML::XPath.first(doc,
        'cas:serviceResponse/cas:authenticationSuccess/cas:user').get_text.value
      #print cas_payload[0] + "\n"
      #print "Returning CAS payload...\n"
      return cas_payload
    end
  end
  
  # login_required filter. add 
  #
  #   before_filter :login_required
  #
  # if the controller should be under any rights management. 
  # for finer access control you can overwrite
  # 
  #   def authorize?(user)
  # 
  def CASACL.login_required(controller)
    if not CASACL.protect?(controller)
      return true
    end
   
    if controller.session[:user]
      # The logged-in user exists in our ACL
      if controller.session[:user_exists]
        #print "\nChecking existing user\n\n"
        return authorize?(User.find_by_login(controller.session[:user]), controller)
      else
      # We're dealing with an ad-hoc user, we must instantiate it
        return authorize?(User.new(:login => controller.session[:user]), controller)
      end
    end
    
    # call overwriteable reaction to unauthorized access
    CASACL.access_denied(controller)
    return false 
  end
  
  # Authorizes the user for an action.
  def CASACL.authorize?(user, controller)
    #required_perm = "%s/%s" % [ controller.controller_name, controller.action_name ]
    required_perm = controller.controller_name
    #print "\nRequired perm: " + required_perm + "\n"
    

    if user.authorized? required_perm
      #print "Granted\n"
      return true
    end
    
    controller.redirect_to "http://www.google.com"
    #print "Denied\n"
    return false
  end
  
  # Checks if a user has permission to view a controller index (for generating menus)
  def CASACL.auth_index?(user, controller)
  #  required_perm = "%s/%s" % [ controller, "index" ]
    required_perm = controller
  

    
    if user.authorized? required_perm
      return true
    end
    
    
    return false
  end
  
  # overwrite this method if you only want to protect certain actions of the controller
  # example:
  # 
  #  # don't protect the login and the about method
  #  def protect?(action)
  #    if ['action', 'about'].include?(action)
  #       return false
  #    else
  #       return true
  #    end
  #  end
  def CASACL.protect?(controller)
    false
  end
  
  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation. 
  # the default action is to redirect to the login screen
  # example use :
  # a popup window might just close itself for instance
  def CASACL.access_denied(controller)
    # Redirect to CA site on failed login
    controller.redirect_to "http://www.yale.edu/cas"
  end
end
