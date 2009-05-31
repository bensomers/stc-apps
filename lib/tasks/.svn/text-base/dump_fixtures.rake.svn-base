desc 'Dump a database to yaml fixtures.'
task :dump_fixtures => :environment do
  path = ENV['FIXTURE_DIR'] || "#{RAILS_ROOT}/data"

  ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
  ActiveRecord::Base.connection.
             select_values('show tables').each do |table_name|
    i = 0
    File.open("#{path}/#{table_name}.yml", 'wb') do |file|
      file.write ActiveRecord::Base.connection.
          select_all("SELECT * FROM #{table_name}").inject({}) { |hash, record|
      hash["#{table_name}_#{i += 1}"] = record
        hash
      }.to_yaml
    end
  end
end