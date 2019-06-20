# frozen_string_literal: true

require "chipmunk"
require 'json'

Given("a preserved Bentley audio artifact") do
  artifact = Fabricate(:stored_package, content_type: "audio")
  Fabricate(:queue_item, package: artifact)

  @artifact_bag_id = artifact.bag_id
  @artifact_package_id = artifact.id
end

Given("I am a Bentley audio content steward") do
  make_me_a("content_manager").on_all("audio")
end

When("I check the status of the artifact") do
  @api_response = api_get("/v1/bags/#{@artifact_bag_id}")

  queue_response_body = json_get("/v1/queue?package=#{@artifact_package_id}",
                                 default_on_failure: [])
  @latest_queue_response_body = queue_response_body.reduce do |lhs, rhs|
    DateTime.parse(lhs["updated_at"]) > DateTime.parse(rhs["updated_at"]) ? lhs : rhs
  end
end

Then("I receive a report that the artifact is preserved") do
  expect(JSON.parse(@api_response.body)['stored']).to eq true
end

Given("an uploaded but not yet preserved Bentley audio artifact") do
  artifact = Fabricate(:package, content_type: "audio")
  Fabricate(:queue_item, package: artifact)

  @artifact_bag_id = artifact.bag_id
  @artifact_package_id = artifact.id
end

Then("I receive a report that the artifact is in progress") do
  expect(JSON.parse(@api_response.body)['stored']).to eq false
  expect(@latest_queue_response_body['status']).to eq('PENDING').or eq('DONE')
end

Given("an uploaded Bentley audio artifact that failed validation") do
  artifact = Fabricate(:package, content_type: "audio")
  Fabricate(:queue_item, package: artifact, status: 1)

  @artifact_bag_id = artifact.bag_id
  @artifact_package_id = artifact.id
end

Then("I receive a report that the artifact is invalid") do
  expect(JSON.parse(@api_response.body)['stored']).to eq false
  expect(@latest_queue_response_body['status']).to eq('FAILED')
end

Given("a Bentley audio artifact that has not been uploaded") do
  @artifact_bag_id = "adsladsjadjsklafdjsa"
  @artifact_package_id = "adsladsjadjsklafdjsa"
end

Then("I receive a report that the artifact has not been received") do
  expect(@api_response.status).to eq 404
end

Given("an uploaded Bentley audio artifact of any status") do
  artifact = Fabricate(:stored_package, content_type: "audio")

  @artifact_bag_id = artifact.bag_id
  @artifact_package_id = artifact.id
end

Given("I have no role") do
  me
end

Then("my request is denied") do
  expect(@api_response.status).to eq 403
end

When("I attempt to download a file in the artifact") do
  @api_response = api_get("/v1/packages/#{@artifact_bag_id}/samplefile")
end

Then("the file is delivered to me as a download") do
  expect(@api_response.status).to eq 200
end

When("I ask for a list of files in the artifact") do
  @api_response = api_get("/v1/bags/#{@artifact_bag_id}")
end

Then("the filenames are delivered to me in a list") do
  expect(JSON.parse(@api_response.body)).to include("files")
  expect(JSON.parse(@api_response.body)["files"]).to be_kind_of(Array)
end
