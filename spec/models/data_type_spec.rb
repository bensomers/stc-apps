require File.dirname(__FILE__) + '/../spec_helper'

describe DataType do
  it "should be valid" do
    DataType.new.should be_valid
  end
end
