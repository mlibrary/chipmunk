Feature: Depositing an artifact
  In order to begin preserving a digital artifact
  As a content manager
  I want to deposit that artifact

  Background:
    Given I am an audio content manager

  Scenario: Initiating a deposit
    When I initiate a deposit of an audio bag
    Then I receive an identifier for the artifact
    And  I receive the path to which to upload the content

  Scenario: Uploading an artifact
    Given an audio deposit has been started
    When I upload the bag
    And signal that the artifact is fully uploaded
    Then the deposit of the artifact is acknowledged

  Scenario: Storing an uploaded artifact
    Given an audio deposit has been completed
    When processing completes
    Then the bag is stored in the repository

  Scenario: A malformed bag is rejected
    Given I have uploaded a malformed bag
    When validation completes
    Then the bag is not stored in the repository
    And I can see the reason it failed
