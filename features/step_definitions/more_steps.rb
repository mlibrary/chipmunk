When("I initiate a deposit of an audio bag") do
  header("Authorization", "Token token=#{@key}")
  @request_response = post(
    "/v1/requests",
    bag_id: "14d25bcd-deaf-4c94-add7-c189fdca4692",
    content_type: "audio",
    external_id: "test_ex_id_22"
  )
end

Then("I receive an identifier for the artifact") do
  expect(@request_response["Location"])
    .to eql("/v1/packages/14d25bcd-deaf-4c94-add7-c189fdca4692")
end

Then("I receive the path to which to upload the content") do
  response = JSON.parse(get("/v1/packages/14d25bcd-deaf-4c94-add7-c189fdca4692").body)
  expect(response['upload_link'])
    .to eql("localhost:/tmp/chipmunk/inc/14d25bcd-deaf-4c94-add7-c189fdca4692")
end

Given("an audio deposit has been started") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I upload the bag") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("signal that the artifact is fully uploaded") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the deposit of the artifact is acknowledged") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("an audio deposit has been completed") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("processing completes") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the bag is stored in the repository") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("I have uploaded a malformed bag") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("validation completes") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the bag is not stored in the repository") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I can see the reason it failed") do
  pending # Write code here that turns the phrase above into concrete actions
end
