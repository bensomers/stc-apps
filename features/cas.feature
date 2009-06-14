Feature: CAS
    In order to penguin
    As a penguin
    I want to penguin

    Scenario: CAS
    Given I have a user named "Cassandra", department "STC", login "cmk49"
    And I am "cmk49"
    And I am on the Data Entries homepage
    Then I should see "cmk49"

