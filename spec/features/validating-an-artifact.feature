Feature: Validating an artifact
  In order to ensure the digital artifact is usable on recovery
  As a content manager
  I want the system to reject malformed artifacts

  Background:
    Given a content manager

  Scenario:
    Given a malformed artifact
    And an initiated deposit
    And an uploaded artifact
    When processing completes
    Then the bag is not stored in the repository
    And the reason is available to the user
