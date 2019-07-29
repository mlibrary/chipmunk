Feature: List the contents of an artifact
  In order to examine whether an artifact is what I am seeking
  As a viewer
  I want to list the materials in an artifact, including its content files and metadata

  Background:
    Given I am a subject librarian

  Scenario: Viewing an artifact
    Given a preserved audio artifact
    When I view the artifact
    Then I see the latest revision
    And I see the artifact metadata
    And I see the list of files in the artifact

  Scenario: Viewing a specific revision of an artifact
    Given a preserved audio artifact with multiple revisions
    When I am seeking a known revision of the artifact
    And I view the artifact
    Then I see the specified revision
