Feature: Checking the status of a deposited artifact
  In order to know which digital artifacts have been preserved
  As a content steward
  I want to check the status of artifacts that have been uploaded

  Scenario: Check on a valid and ingested artifact
    Given a preserved Bentley audio artifact
    And I am a Bentley audio content steward
    When I check on the artifact
    Then I receive a report that the artifact is preserved

  Scenario: Check on an artifact that has been uploaded but isn't preserved yet
    Given an uploaded but not yet preserved Bentley audio artifact
    And I am a Bentley audio content steward
    When I check on the progress processing the artifact
    Then I receive a report that the artifact is in progress

  Scenario: Check on an invalid artifact that has been uploaded
    Given an uploaded Bentley audio artifact that failed validation
    And I am a Bentley audio content steward
    When I check on the progress processing the artifact
    Then I receive a report that the artifact is invalid

  @allow-rescue
  Scenario: Check on an artifact that has not yet been uploaded
    Given a Bentley audio artifact that has not been uploaded
    And I am a Bentley audio content steward
    When I check on the artifact
    Then I receive a report that the artifact has not been received

  Scenario: Check on an artifact without permission
    Given an uploaded Bentley audio artifact of any status
    And I have no role
    When I check on the artifact
    Then my request is denied
