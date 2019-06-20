Feature: Listing files within an artifact
  In order to deliver a preserved content item to a researcher
  As a content steward
  I want to view a list of files in artifacts that have been ingested

  Background:
    Given a preserved Bentley audio artifact

  Scenario: List files successfully
    Given I am a Bentley audio content steward
    When I ask for a list of files in the artifact
    Then the filenames are delivered to me in a list

  Scenario: Try to list files without permission
    Given I have no role
    When I ask for a list of files in the artifact
    Then my request is denied
