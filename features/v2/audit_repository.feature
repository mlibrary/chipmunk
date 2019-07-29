Feature: Auditing the repository
  In order to ensure repository integrity
  As a repository administrator
  I want to audit the repository's content

  Background:
    Given I am a repository administrator
    And 2 preserved Bentley audio artifacts

  Scenario: Initiating an audit
    When I initiate an audit
    Then I learn where the audit is being tracked

  Scenario: Viewing the result of an audit
    Given I have initiated an audit
    When I ask for the status of the audit
    Then I see that 2 packages were audited
    And I see how many have failed
