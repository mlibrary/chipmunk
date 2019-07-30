Feature: Revise an artifact in the repository
  In order to preserve a new edition of an artifact
  As a content steward
  I want to deposit the updated content and have it be recorded as a new revision rather than a new artifact

  There is some conceptual overlap with the initial deposit of an artifact. The
  same basic technical constraints apply; uploads are always handled as BagIt
  Bags. There is interest in incremental "patches" to metadata or contents for
  future functionality.

  Background:
    Given I am a Bentley audio content steward

  Scenario: Uploading a new edition
    Given a preserved audio artifact
    When I revise the artifact by uploading a new edition
    Then the artifact has one new revision
    And the contents are updated to match my new edition

  @wip
  Scenario: Adding metadata to an existing artifact
    Given a preserved audio artifact
    When I upload new metadata that includes a link to an ArchivesSpace record
    Then the artifact has one new revision
    And the link is included in the latest metadata

  @wip
  Scenario: Adding a file to an existing artifact
    Given a preserved audio artifact
    When I upload a new file to be included in the artifact
    Then the artifact has one new revision
    And the file is included in the latest manifest
