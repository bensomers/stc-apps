Feature: Data
    In order to manage data for things like printers and staplers
    As an administrator
    I want to create, edit, view and destroy data objects

    Scenario Create a Data type
        Given I am a superuser
        And I am on the list of data
        When I follow "Create new data type"
        And I fill in "Name" with "Ring"
        And I fill in "Description" with "The Rings of Power"
        And I fill in "Data Field Name" with "Evil"
        And I select "Radio buttons" from "Display Type"
        And I fill in "Values" with "yes, no"
        And I follow "New data field" #this is necessarily non-Ajax because Cucumber does not support Java
        And I fill in "Data Field Name" with "Metals"
        And I select "Check Box" from "Display Type"
        And I follow "New data field"
        And I fill in "Data Field Name" with "Description of type of magic"
        And I select "Text Area" from "Display Type"
        And I press "Create"
        Then I should see "New data type created."
        And I should see "Ring"
        And I should see "The Rings of Power"

    Scenario: Show Data
        Given I have data types:
        |Data Type Name|Data Type Description|Field Display Type|Field Name|Field Values     |Alert        |
        |Rings         |The Rings of Power   |Radio Button      |Evil      |yes, no          |nil          |
        |Space Ships   |Vehicles to travel   |Select            |Model     |Deathstar, Falcon|nil          |
        |Printers      |Are boring           |Text field        |Page count|int              |min=50,max=50|
        And I have the following Data Objects
        |Data Object Name|Data Object Description|Data Type  |
        |The One Ring    |one to rule them all   |Rings      |
        |Millenium Falcon|Hans Solo has a ship   |Space Ships|
        |BW Printer      |Printer in BK cluster  |Printers   |
        And I am on the Data Type main page`
        When I select "Show"
        ???


General
  Export data to CSV for all objects of a type, a subset of objects (of same) type, maybe more?

Types
  Index Page shows all types for Dept
  Create
    Create a new type with Name, Description, and fields.
    Should be able to add multiple fields without submitting or refreshing the page (use ajax)
  Show
    List all objects of that type
    Add more objects of that type
  Edit
    Edit fields, name, and description
  Destroy
    Destroying a type destroys all objects of that type
    Destroys all data entries

Objects
  Index page shows all objects, sortable by type, name, location, and last updated
    Hovering over an object shows a quickview of last update? Maybe
    Clicking takes you to show action for that object
  Create
    Allows you to choose the type, name, description, and location affiliations
  Show
    The show page should show all recent data entries about an object, with an option to export that data to CSV
  Edit
    Edit name
  Destroy
    Destroys all data entries for that object

Fields
  No 'exposed' field controller

Entries
  No exposed entries controller

