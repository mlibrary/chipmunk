# frozen_string_literal: true

require "chipmunk/bag"
require "json"
require "fileutils"

When("I initiate a deposit of an audio bag") do
  api_post(
    "/v1/requests",
    bag_id: @bag.id,
    content_type: @bag.content_type,
    external_id: @bag.external_id
  )
end

Then("I learn where my request is being tracked") do
  expect(last_response["Location"]).to eql("/v1/packages/#{@bag.id}")
end

When("I check on my request") do
  api_get("/v1/packages/#{@bag.id}")
end

Then("I receive the path to which to upload the content") do
  upload_link = JSON.parse(last_response.body)["upload_link"]
  expect(upload_link).to eql("#{Chipmunk.config.upload.rsync_point}/#{@bag.id}")
end

When("I upload the bag") do
  FileUtils.cp_r @bag.bag_dir, @package.upload_link.split(":").last
end

When("signal that the artifact is fully uploaded") do
  api_post("/v1/requests/#{@bag.id}/complete")
end

Then("the deposit of the artifact is acknowledged") do
  expect(api_get(last_response["Location"]).status).to eql(200)
end

Then("the bag is stored in the repository") do
  expect(Services.storage.for(@package.reload)).to be_valid
end

Then("the bag is not stored in the repository") do
  expect do
    Services.storage.for(@package.reload)
  end.to raise_error Chipmunk::PackageNotStoredError
end
