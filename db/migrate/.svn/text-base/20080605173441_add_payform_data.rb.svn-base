require 'active_record/fixtures'

class AddPayformData < ActiveRecord::Migration
  def self.up
    down
    env_dir = ENV['RAILS_ENV'] =='production' ? "production_data" : "development_data"
    directory = File.join(File.dirname(__FILE__), env_dir)
    self.add_fixtures ["categories","payforms","payform_items", "payform_configurations", "payform_items_payforms"], directory
  end
  
  def self.add_fixtures(fixtures, directory)
    for fixture in fixtures
      Fixtures.create_fixtures(directory, fixture)
    end
  end

  def self.down
    Category.delete_all
    PayformItem.delete_all
  end
end
