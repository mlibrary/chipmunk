Feature: Deposit a new artifact into the repository
  In order to preserve a culturally significant digital object
  As a content steward
  I want to deposit an artifact into the repository

  Uploads are always handled as BagIt Bags as of now. When we discuss a digital
  object, we mean the artifact as it is exists for local storage or transfer.
  When we discuss an artifact without qualification, we mean one that has been
  successfully deposited into the repository.

  Background:
    Given I am a content steward

  Scenario: Depositing a new artifact
    Given an audio object that is not in the repository
    When I deposit the object as a bag
    Then it is preserved as an artifact
    And the artifact has the identifier from within the bag

  Scenario: Duplicate deposit
    Given a preserved audio artifact
    When I attempt to deposit the object as a bag to create a new artifact
    Then it is rejected as already preserved
