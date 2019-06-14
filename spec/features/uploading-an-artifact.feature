Feature: Uploading an artifact
  In order to begin preserving a digital artifact
  As a content manager
  I want to deposit that artifact

  Background:
    Given a content manager

  Scenario: Initiating a deposit
    Given a valid artifact
    When the content manager initiates the deposit of the artifact
    Then they receive an identifier for the artifact
    And  they receive the path to which to upload the artifact

  Scenario: Uploading an artifact
    Given an initiated deposit
    When the content manager uploads the artifact
    And signals that the artifact is fully uploaded
    Then the deposit of the artifact is acknowledged

  Scenario: Storing an uploaded artifact
    Given an initiated deposit
    And an uploaded artifact
    When processing completes
    Then the bag is stored in the repository
