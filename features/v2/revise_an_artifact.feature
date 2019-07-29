Feature: Revising an artifact in the repository
  In order to preserve a new revision of an artifact
  As a content steward
  I want to deposit the updated content
  And have it be treated as a new revision rather than a new artifact

  Background:
    Given an artifact with one revision in the repository
    And I have a new revision of my Bentley audio bag to deposit
    And I am a Bentley audio content steward

  Scenario: Initiating a deposit
    When I initiate a deposit of an audio bag
    Then I learn where my request is being tracked

  Scenario: Finding upload location
    Given a new deposit for my artifact
    When I check on the deposit
    Then I receive the path to which to upload the content

  Scenario: Uploading an artifact
    Given a new deposit for my artifact
    When I upload the bag
    And I signal that the artifact is fully uploaded
    Then the deposit of the artifact is acknowledged
    And the deposit is ingesting

  Scenario: Preserving an artifact
    Given an in progress deposit for my artifact
    When the deposit's ingest completes
    Then the new revision is attached to the artifact
