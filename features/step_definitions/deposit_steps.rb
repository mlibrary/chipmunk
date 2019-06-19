# frozen_string_literal: true

Given("a preserved Bentley audio artifact") do
  @artifact ||= Fabricate(:stored_package, content_type: "audio")
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
  @bags_response = JSON.parse(get("/v1/bags/#{@artifact.bag_id}").body)
  @queue_response = JSON.parse(get("/v1/queue?package=#{@artifact.bag_id}").body)
end

Then("I receive a report that the artifact is preserved") do
  expect(@bags_response['stored']).to eq true
end

Given("an uploaded but not yet preserved Bentley audio artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive a report that the artifact is in progress") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("an uploaded Bentley audio artifact that failed validation") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive a report that the artifact is invalid") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("a Bentley audio artifact that has not been uploaded") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive a report that the artifact has not been received") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("an uploaded Bentley audio artifact of any status") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("I have no role") do
  @key ||= Keycard::DigestKey.new
  @user ||= Fabricate(:user, api_key_digest: @key.digest)
end

Then("I receive a report that I lack permission to view the artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I attempt to download a file in the artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the file is delivered to me as a download") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the file is not delivered") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I ask for a list of files in the artifact") do
  header("Authorization", "Token token=#{@key}")
  @package_response = JSON.parse(get("/v1/packages/#{@artifact.bag_id}").body)
end

Then("the filenames are delivered to me in a list") do
  bag = Services.storage.for(@artifact)
  expect(@package_response['files']).to eql(bag.relative_data_files.map(&:to_s))
end

Then("the filenames are not delivered") do
  expect(@package_response.has_key?('files')).to be false
end
