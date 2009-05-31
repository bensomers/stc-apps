#Given payform with last date <eee>
Given /^payform with last date (.*)$/ do |s|
  @date = Date.parse s
  
end

When "I change to that payform" do

end

Then /^I should have payform starting from (.*)$/ do |s|
  end_date = Date.parse(s) + 6
  @date.should == end_date
end
