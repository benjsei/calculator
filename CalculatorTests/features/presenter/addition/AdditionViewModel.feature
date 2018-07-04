@additionViewModel
Feature: addition

Scenario: I add 4 and 5 in see 9
Given I am filling 4 in the first field
When I am filling 5 in the second field
Then I see 9 in the result label

Scenario: I add 4 and 6 in see 10
Given I am filling 4 in the first field
When I am filling 6 in the second field
Then I see 10 in the result label
