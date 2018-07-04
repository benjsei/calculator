@oddViewModel
Feature: Odd

Scenario: Integer 4 is red
Given I am filling 4 in the field to evalute
When I am tapping in the evaluate button
Then I see the evaluate button red

Scenario: Integer 5 is green
Given I am filling 5 in the field to evalute
When I am tapping in the evaluate button
Then I see the evaluate button green
