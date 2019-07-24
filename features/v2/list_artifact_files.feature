Feature: Listing files within an artifact
  In order to deliver a preserved content item to a researcher
  As a content steward
  I want to view a list of files in artifacts that have been ingested

  Background:
    Given I am a Bentley audio content steward

  Scenario: List files successfully
    Given a preserved Bentley audio artifact
    When I ask for a list of files in the artifact
    Then the filenames are delivered to me in a list

