Feature: Create Payform
  In order to bill for money
  As an STC user
  I want to create payform

  Scenario Outline: create new payform for a certain week
    Given payform with last date <end_date>
    When I change to that payform
    Then I should have payform starting from <start_date>

  Examples:
    | end_date  | start_date|
    | 2008-12-27| 2008-12-21|
    | 2009-01-03| 2008-12-28|