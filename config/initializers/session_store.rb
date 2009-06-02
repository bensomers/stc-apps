# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_stc-apps_session',
  :secret      => '2f91af9f29ae181724d8b6a6240f7f69272cb17c45f73b936a78f47ed6c3d9d86918716563173d3cf8b5e53bc45b2ead16d3f032a781e1147ad1210852e790e7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
