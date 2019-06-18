# frozen_string_literal: true

Given("a preserved Bentley audio artifact") do
  @artifact = Fabricate(:stored_package, content_type: "audio")
end

Given("I am a Bentley audio content steward") do
  make_me_a("content_manager").on_all("audio")
end

When("I check the status of the artifact") do
  api_get("/v1/bags/#{@artifact.bag_id}")
end

Then("I receive a report that the artifact is preserved") do
  artifact = JSON.parse(last_response.body)
  expect(artifact['stored']).to eq true
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
  pending # Write code here that turns the phrase above into concrete actions
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
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the filenames are delivered to me in a list") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the filenames are not delivered") do
  pending # Write code here that turns the phrase above into concrete actions
end
