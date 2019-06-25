require "json"

When("I ask for a list of files in the artifact") do
  @package_response = api_get("/v1/packages/#{@package.bag_id}")
end

Then("the filenames are delivered to me in a list") do
  expect(JSON.parse(@package_response.body)).to include("files")
  expect(JSON.parse(@package_response.body)["files"]).to be_kind_of(Array)
end
