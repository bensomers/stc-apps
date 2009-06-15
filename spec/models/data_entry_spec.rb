require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module DataEntryHelper
  def valid_data_entry_attributes
    { :data_object_id => "1",
      :content => "It's green!"
    }
  end
end

describe DataEntry do
  include DataEntryHelper

  describe "when newly created" do
    before(:each) do
      @data_entry = DataEntry.new
    end

    it "should be valid with valid attributes" do
      @data_entry.attributes = valid_data_entry_attributes
      @data_entry.should be_valid
    end

    [:data_object_id, :content].each do |attribute|
      it "should not be valid without #{attribute}" do
        @data_entry.attributes = valid_data_entry_attributes.except(attribute)
        @data_entry.should_not be_valid
      end
    end

  end
end

