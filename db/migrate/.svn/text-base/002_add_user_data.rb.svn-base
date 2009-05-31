require 'active_record/fixtures'

class AddUserData < ActiveRecord::Migration
  def self.up
    down
    env_dir = ENV['RAILS_ENV'] =='production' ? "production_data" : "development_data"
    directory = File.join(File.dirname(__FILE__), env_dir)
    self.add_fixtures ["users", "roles", "roles_users", "permissions", "permissions_roles", "departments", "departments_roles", "departments_users", "groups", "groups_users", "groups_roles", "departments_groups"], directory
  end
  
  def self.add_fixtures(fixtures, directory)
    for fixture in fixtures
      Fixtures.create_fixtures(directory, fixture)
    end
  end

  #if we use HABTM relationship, there are no join model, only join tables
  #TODO: put the query to delete all from those join tables. -H
  def self.down
    User.delete_all
    Role.delete_all
    Permission.delete_all
    Department.delete_all
    Group.delete_all
  end
end
