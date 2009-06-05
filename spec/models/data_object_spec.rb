require File.dirname(__FILE__) + '/../spec_helper'

describe DataObject do
  it "should be valid" do
    DataObject.new.should be_valid
  end
end
