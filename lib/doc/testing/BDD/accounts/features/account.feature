Feature: My Account
  In order to manage my account
  As a money minder
  I want to ensure my money doesn't get lost

  Scenario: Taking out money
    Given I have an account
    And it has a balance of 100
    When I take out 10
    Then my balance should be 90
