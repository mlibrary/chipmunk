Feature: Download an artifact as a Bag
  In order to browse the images in a preserved collection
  As a subject librarian (viewer)
  I want to download the latest version of an artifact's content in a convenient package

  As with deposits, we only offer complete artifacts for download as BagIt Bags.

  Background:
    Given I am a subject librarian

  Scenario: Downloading a complete artifact
    Given a preserved audio artifact
    When I download the complete artifact
    Then I receive the latest revision as a bag

  Scenario: Downloading an older revision
    Given a preserved audio artifact
    When I am seeking a known revision of the artifact
    And I download the complete artifact
    Then I receive the specified revision as a bag
