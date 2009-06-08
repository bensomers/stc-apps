Feature: Managing stickies
  In order to manage stickies
  As a normal user
  I want to be able to create, delete, and view stickies
  
  Scenario Outline: Viewing stickies on shift
    Given I am logged into a shift in <location>
    When I am on the shift report page
    Then I should see all stickies belonging to <location>
    And I should see all stickies belonging to <location group>
  
  Scenarios: it works

  | location   | location group  |
  | CT Hall    | Public Clusters |
  | Dunham     | Public Clusters |
  | JE         | College         |
  | TC         | College         |
  | Io         | IO              |
  | Bass Media | Bass Media      |
  | Bluedog    | Grad Support    |


  Scenario: Viewing stickies on shifts index
    Given I am on the shifts index
    Then I should see "Stickies"
  

