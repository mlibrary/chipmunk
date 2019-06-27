# frozen_string_literal: true

Then("the file is delivered to me as a download") do
  expect(@package_response.status).to eq 200
end

When("I attempt to download a file in the artifact") do
  @package_response = api_get("/v1/packages/#{@package.bag_id}/samplefile")
end
