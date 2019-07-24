Feature: Protecting the repository
  In order to protect the repository and its operations
  As a repository administrator
  I want to deny unauthorized requests

  Background:
    Given I have no role

  Scenario: Try to initiate an audit without permission
    When I initiate an audit
    Then my request is denied

  Scenario: Check on a deposit without permission
    Given a deposit
    When I check on the deposit
    Then my request is denied

  Scenario: Try to initiate a deposit without permission
    Given I have a Bentley audio bag to deposit
    When I initiate a deposit of an audio bag
    Then my request is denied

  Scenario: Try to list files without permission
    Given a preserved Bentley audio artifact
    When I ask for a list of files in the artifact
    Then my request is denied
