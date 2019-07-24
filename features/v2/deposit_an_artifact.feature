Feature: Depositing an artifact
  In order to begin preserving a digital artifact
  As a content steward
  I want to deposit that artifact

  Background:
    Given I am a Bentley audio content steward

  Scenario: Initiating a deposit
    Given I have a Bentley audio bag to deposit
    When I initiate a deposit of an audio bag
    Then I learn where my request is being tracked

  Scenario: Finding upload location
    Given a new deposit
    When I check on the deposit
    Then I receive the path to which to upload the content

  Scenario: Uploading an artifact
    Given a new deposit
    And I have a Bentley audio bag to deposit
    When I upload the bag
    And I signal that the artifact is fully uploaded
    Then the deposit of the artifact is acknowledged
    And the deposit is ingesting

  Scenario: Preserving an artifact
    Given an in progress deposit
    When the deposit's ingest completes
    Then the bag is stored in the repository

