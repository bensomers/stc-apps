Feature: data types
  In order to manage data types
  As an admin
  I want to be able to create and maintain data types

    Scenario: Create a Data type
        Given I am "ja"
        And I have no data_types
        And I am on the data types page
        When I follow "Create new data type"
        And I fill in "Name" with "Ring"
        And I fill in "Description" with "The Rings of Power"
        And I fill in "Data Field Name" with "Evil"
        And I select "Radio buttons" from "Display Type"
        And I fill in "Values" with "yes, no"
        And I follow "New data field"
        And I fill in "Data Field Name" with "Metals"
        And I select "Check Box" from "Display Type"
        And I follow "New data field"
        And I fill in "Data Field Name" with "Description of type of magic"
        And I select "Text Area" from "Display Type"
        And I press "Create"
        Then I should see "New data type created."
        And I should see "Ring"
        And I should see "The Rings of Power"

