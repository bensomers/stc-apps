require File.dirname(__FILE__) + '/../spec_helper'

describe DataField do
  it "should be valid" do
    DataField.new.should be_valid
  end
end
