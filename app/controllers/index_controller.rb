

class IndexController < ApplicationController
  # Check authentication with CAS login
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :chooser
  
  def index
  end
end
