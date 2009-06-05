require File.dirname(__FILE__) + '/../spec_helper'

describe DataEntry do
  it "should be valid" do
    DataEntry.new.should be_valid
  end
end
