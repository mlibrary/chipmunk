@checkpoint_transaction
Feature: End to End functionality
  As an digitization technician
  I want to upload packages
  So that I can verify their upload

  Background:
    Given time is frozen at "2017-05-17 18:49:08 UTC"
    And I am a audio content manager with username testuser
    And I send and accept JSON
    And upload.upload_path is "data/incoming"
    And upload.rsync_point is "localhost:data/incoming"
    And upload.storage_path is "data/storage"
    And validation.external.audio is "true"

  Scenario Outline: Create initial request and verify
    Given "data/incoming" exists and is empty
    And "data/storage" exists and is empty

    When I send a POST request to "/v1/requests" with this json:
      | bag_id | <bag_id>             |
      | content_type | audio          |
      | external_id  | <external_id>  |
    Then the response status should be "201"
    And the response should be empty
    And the response should have the following headers:
      | Location | /v1/packages/<bag_id> |
    When I send a GET request to "/v1/requests/<bag_id>"
    Then the response status should be "200"
    And the JSON response should be:
      | bag_id        | <bag_id>                             |
      | user          | <username>                           |
      | content_type  | audio                                |
      | external_id   | <external_id>                        |
      | stored        | false                                |
      | upload_link   | localhost:data/incoming/<bag_id> |
      | created_at    | 2017-05-17 18:49:08 UTC              |
      | updated_at    | 2017-05-17 18:49:08 UTC              |
    # simulates action of correctly-configured rsync (out of scope of the application)
    When I copy a test bag to "data/incoming/<bag_id>"
    Then copy finishes successfully
    When I send an empty POST request to "/v1/requests/<bag_id>/complete"
    Then the response status should be "201"
    And the response should be empty
    And the response should have the following headers:
      | Location | /v1/queue/1 |
    When I send a GET request to "/v1/queue/1"
    Then the response status should be "200"
    And the JSON response should be:
      | id            |   1                                  |
      | request       | /v1/requests/<bag_id>                |
      | status        | DONE                                 |
      | package       | /v1/packages/<bag_id>                |
      | created_at    | 2017-05-17 18:49:08 UTC              |
      | updated_at    | 2017-05-17 18:49:08 UTC              |
    When I send a GET request to "/v1/packages/<bag_id>"
    Then the response status should be "200"
    And the JSON response should be:
      | bag_id        | <bag_id>                             |
      | user          | <username>                           |
      | content_type  | audio                                |
      | external_id   | <external_id>                        |
      | files         | samplefile                           |
      # see PFDR-66 (this is present for completed bags after the request/bag merger)
      | stored        | true                                 |
      | upload_link   | localhost:data/incoming/<bag_id> |
      | created_at    | 2017-05-17 18:49:08 UTC              |
      | updated_at    | 2017-05-17 18:49:08 UTC              |

  Examples:
    | bag_id                                | external_id   | username |
    | 14d25bcd-deaf-4c94-add7-c189fdca4692  | test_ex_id_22 | testuser |
