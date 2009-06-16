Given /^I have a user named "([^\"]*)", department "([^\"]*)", login "([^\"]*)"$/ do |name, department, login|
  d = Department.find_by_name("#{department}") or Department.create!(:name => department)

  u = User.new(:name => name, :login => login)
  u.departments << Department.find_by_name("#{department}")
  u.save!

end

Given /^I am "([^\"]*)"$/ do |user_login|

#  @department = @user.departments[0]
  CASClient::Frameworks::Rails::Filter.fake(user_login)
#  @user = User.find_by_login(user_login)

#  this seems like a clumsy way to set the department but I can't figure out any other way - wei
#  visit departments_path
#  click_link @department.name
#  Department.find session["current_chooser_choice"][controller_name]
end

Given /^the user "([^\"]*)" has permissions "([^\"]*)"$/ do |user_name, permissions|
    user = User.find_by_name(user_name)
    permissions.split(", ").each do |permission_name|
    user.permissions << Permission.find_by_name(permission_name)
  end
end


Given /^I have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

Then /^I should have no (.+)$/ do |class_name|
  class_name.classify.constantize.count.should == 0
end


Given /^I have no (.+)$/ do |class_name|
  class_name.classify.constantize.delete_all
end

Then /^I should have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

Given /^I have a department named "([^\"]*)"$/ do |department|
  Department.create!(:name => department)
end

Given /^I have locations "([^\"]*)" in location group "([^\"]*)" for the department "([^\"]*)"$/ do |locations, location_group, department|
  locations.split(", ").each do |location_name|
  loc_group = LocationGroup.find_by_long_name(location_group)
  Location.create!(:long_name => location_name, :location_group_id => loc_group.id,
                   :min_staff => 1, :max_staff => 3, :short_name => location_name)
  end
end
