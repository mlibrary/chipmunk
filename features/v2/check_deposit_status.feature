Feature: Checking the status of a deposit
  In order to know which deposits have completed
  As a content steward
  I want to check the status of my deposits

  Background:
    Given I am a Bentley audio content steward

  Scenario: Check on a successful deposit
    Given a completed deposit
    When I check on the deposit
    Then I receive a report that the deposit is completed

  Scenario: Check on an in progress deposit
    Given an in progress deposit
    When I check on the deposit
    Then I receive a report that the deposit is ingesting

  Scenario: Check on a deposit of an invalid artifact
    Given a failed deposit
    When I check on the deposit
    Then I receive a report that the deposit failed
    And I receive a report that the artifact is invalid

  @allow-rescue
  Scenario: Check on a new deposit
    Given a new deposit
    When I check on the deposit
    Then I receive a report that the deposit is started

