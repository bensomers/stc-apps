# Add the necessary route to routes.rb

puts "Adding taskr4rails route to your routes.rb file..."

routes_file = File.expand_path("#{RAILS_ROOT}/config/routes.rb")

routes = IO.read(routes_file)
find = "ActionController::Routing::Routes.draw do |map|"
idx = routes.index(find)

unless idx
  $stderr.puts "Couldn't add taskr4rails route. You will have to do this manually."
  exit
end

File.open(routes_file, "w") do |io|
  loc = idx + find.length
  
  ins = %{  }+$/+$/+
        %{  # route automatically added by taskr4rails plugin}+$/+
        %{  map.taskr4rails "taskr4rails", :controller => 'taskr4rails', :action => 'execute'}+$/+$/
        
  routes.insert(loc, ins)
  
  io.write(routes)
end