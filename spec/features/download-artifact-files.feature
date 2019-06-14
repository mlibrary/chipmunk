Feature: Downloading files within an artifact
  In order to deliver a preserved content item to a researcher
  As a content steward
  I want to download files from artifacts that have been ingested

  Background:
    Given a preserved Bentley audio artifact

  Scenario: Download file successfully
    Given I am a Bentley audio content steward
    When I attempt to download a file in the artifact
    Then the file is delivered to me as a download

  Scenario: Try to download a file without permission
    Given I have no role
    When I attempt to download a file in the artifact
    Then the file is not delivered
