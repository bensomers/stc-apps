require 'cas_acl'

class IndexController < ApplicationController
  # Check authentication with CAS login
  before_filter CASACL::CASFilter
  before_filter :chooser
  
  def index
  end
end
