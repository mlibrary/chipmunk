Feature: Rejecting a malformed artifact
  In order to avoid preserving digital artifacts that have no value to me
  As a content steward
  I want malformed artifacts to be rejected

  Background:
    Given I am a Bentley audio content steward
    And I have a malformed Bentley audio bag to deposit

  Scenario: A malformed bag is rejected
    Given a new deposit
    When I upload the bag
    And signal that the artifact is fully uploaded
    Then the bag is not stored in the repository
