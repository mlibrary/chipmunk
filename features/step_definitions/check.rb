# frozen_string_literal: true

When("I check on the artifact") do
  @package_response = api_get("/v1/packages/#{@package.bag_id}")
end

When("I check on the progress processing the artifact") do
  @queue_response = api_get("/v1/queue?package=#{@package.id}")
end

Then("I receive a report that the artifact is preserved") do
  expect(JSON.parse(@package_response.body)["stored"]).to eq true
end

Then("I receive a report that the artifact is in progress") do
  expect(JSON.parse(@queue_response.body).first["status"])
    .to eq("PENDING").or eq("DONE")
end

Then("I receive a report that the artifact is invalid") do
  expect(JSON.parse(@queue_response.body).first["status"]).to eq("FAILED")
end

Then("I receive a report that the artifact has not been received") do
  expect(@package_response.status).to eq 404
end
