Given /^I have a user named "([^\"]*)", department "([^\"]*)", login "([^\"]*)"$/ do |name, department, login|
  d = Department.find_by_name("#{department}") or Department.create!(:name => department)

  u = User.new(:name => name, :login => login)
  u.departments << Department.find_by_name("#{department}")
  u.save!

end

Given /^I am "([^\"]*)"$/ do |user_name|
  @user = User.find_by_login(user_name)
#  @department = @user.departments[0]
  CASClient::Frameworks::Rails::Filter.fake(@user.login)
  #this seems like a clumsy way to set the department but I can't figure out any other way - wei
#  visit departments_path
#  click_link @department.name
#  Department.find session["current_chooser_choice"][controller_name]
end

