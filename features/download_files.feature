Feature: Downloading files within an artifact
  In order to deliver a preserved content item to a researcher
  As a content steward
  I want to download files from artifacts that have been preserved

  Scenario: Download file successfully
    Given I am a content steward
    And a preserved audio artifact with multiple revisions
    When I attempt to download a file in the artifact
    Then I receive the latest revision of the file as a download

  Scenario: Download file from an older revision
    Given I am a content steward
    And a perserved audio artifact with multiple revisions
    When I am seeking a known revision of the artifact
    And I attempt to download a file from the artifact
    Then I receive the specified revision of the file as a download

  Scenario: Try to download a file without permission
    Given I have no role
    When I attempt to download a file in the artifact
    Then my request is denied

