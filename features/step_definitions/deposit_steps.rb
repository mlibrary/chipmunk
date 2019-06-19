# frozen_string_literal: true

require "chipmunk"
require 'json'

Given("a preserved Bentley audio artifact") do
  @artifact ||= Fabricate(:stored_package, content_type: "audio")
  Fabricate(:queue_item, package: @artifact)
end

Given("I am a Bentley audio content steward") do
  @key ||= Keycard::DigestKey.new
  @user ||= Fabricate(:user, api_key_digest: @key.digest)
  Services.checkpoint.grant!(
    @user,
    Checkpoint::Credential::Role.new('content_manager'),
    Checkpoint::Resource::AllOfType.new('audio')
  )
end

When("I check the status of the artifact") do
  header("Authorization", "Token token=#{@key}")
  begin
    @bags_response ||= get("/v1/bags/#{@artifact.bag_id}")
  rescue ActiveRecord::RecordNotFound
    @bags_response ||= Rack::MockResponse.new(404, {}, '')
  end

  begin
    queue_response_body ||= JSON.parse(get("/v1/queue?package=#{@artifact.id}").body)

    @latest_queue_response_body ||= queue_response_body.reduce do |lhs, rhs|
      DateTime.parse(lhs["updated_at"]) > DateTime.parse(rhs["updated_at"]) ? lhs : rhs
    end
  rescue JSON::ParserError
    @latest_queue_response_body ||= {}
  end
end

Then("I receive a report that the artifact is preserved") do
  expect(JSON.parse(@bags_response.body)['stored']).to eq true
end

Given("an uploaded but not yet preserved Bentley audio artifact") do
  @artifact ||= Fabricate(:package, content_type: "audio")
  Fabricate(:queue_item, package: @artifact)
end

Then("I receive a report that the artifact is in progress") do
  expect(JSON.parse(@bags_response.body)['stored']).to eq false
  expect(@latest_queue_response_body['status']).to eq('PENDING').or eq('DONE')
end

Given("an uploaded Bentley audio artifact that failed validation") do
  @artifact ||= Fabricate(:package, content_type: "audio")
  Fabricate(:queue_item, package: @artifact, status: 1)
end

Then("I receive a report that the artifact is invalid") do
  expect(JSON.parse(@bags_response.body)['stored']).to eq false
  expect(@latest_queue_response_body['status']).to eq('FAILED')
end

Given("a Bentley audio artifact that has not been uploaded") do
  class ArtifactStub
    def bag_id
      "adsladsjadjsklafdjsa"
    end

    def id
      "adsladsjadjsklafdjsa"
    end
  end

  @artifact ||= ArtifactStub.new
end

Then("I receive a report that the artifact has not been received") do
  expect(@bags_response.status).to eq 404
end

Given("an uploaded Bentley audio artifact of any status") do
  @artifact ||= Fabricate(:stored_package, content_type: "audio")
end

Given("I have no role") do
  @key ||= Keycard::DigestKey.new
  @user ||= Fabricate(:user)
end

Then("I receive a report that I lack permission to view the artifact") do
  expect(@bags_response.status).to eq 401
end

When("I attempt to download a file in the artifact") do
  header("Authorization", "Token token=#{@key}")
  @file_response ||= get("/v1/packages/#{@artifact.bag_id}/samplefile")
end

Then("the file is delivered to me as a download") do
  expect(@file_response.status).to eq 200
end

Then("the file is not delivered") do
  expect(@file_response.status).to eq 401
end

When("I ask for a list of files in the artifact") do
  header("Authorization", "Token token=#{@key}")
  @file_list_response ||= get("/v1/bags/#{@artifact.bag_id}")
end

Then("the filenames are delivered to me in a list") do
  expect(JSON.parse(@file_list_response.body)).to include("files")
  expect(JSON.parse(@file_list_response.body)["files"]).to be_kind_of(Array)
end

Then("the filenames are not delivered") do
  expect(@file_list_response.status).to eq 401
end
