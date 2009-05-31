desc "Reset Database data to that in fixtures that were dumped"
task :load_dumped_fixtures => :environment do
  require 'active_record/fixtures'
  ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
  path = ENV['FIXTURE_DIR'] || "#{RAILS_ROOT}/data"
  Dir.glob("#{path}/*.{yml}").each do |fixture_file|
    Fixtures.create_fixtures(path, File.basename(fixture_file, '.*'))
  end
end