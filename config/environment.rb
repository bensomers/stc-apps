# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'


#Rubycas plugin stuff (not necessary)
#require 'casclient'
#require 'casclient/frameworks/rails/filter'



# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

#---------------------------------------------
# taskr and taskr4rails
#---------------------------------------------
TASKR4RAILS_AUTH = "stc_493"
TASKR4RAILS_ALLOWED_HOSTS = ['127.0.0.1'] #separate by commas if more hosts allowed

#TODO: create new taskr task

# :schedule => "cron 30 19 * * 6"  # 7:30pm every Saturday
# :action => taskr4rails
# :url => "http://localhost:3000/taskr4rails" (or whatever the production environment is)
# :auth => "stc_493"
# :ruby_code => "PayformTask.remind; PayformTask.warn"

#---------------------------------------------

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  #THIS IS FOR NATHAN'S APACHE SETUP -- comment it out if he forgets
  #config.action_controller.relative_url_root = "/stc-apps"

  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # See Rails::Configuration for more options

  # Configure Rails Mail options
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "mail.yale.edu",
    :port => 587,
    :domain => "yale.edu",

    #for some reason, :authentication => login is not working
    #thus, for now, the server will have to be connected to the yale network
    #to be able to send emails
  }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_charset = "utf-8"

  # Include all gems below:
  # Configure PDF Writer
  # I comment this line out because initializer/date_formats.rb does not load properly with it
  config.gem "pdf-writer", :lib => 'pdf/writer'
  config.gem "ruby-net-ldap", :lib => 'net/ldap'
  config.gem "fastercsv", :lib => false
  config.gem "icalendar", :lib  => false


  # Testing using taskr to run background processes
  # config.gem "taskr"
  # config.gem "rubycas-client"
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

#Configure CAS
CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://secure.its.yale.edu/cas/"
)

