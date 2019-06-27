Given(/(\d*) preserved Bentley audio artifacts/) do |quantity|
  Fabricate.times(Integer(quantity), :stored_package, content_type: "audio")
end

Given("a preserved Bentley audio artifact") do
  @package = Fabricate(:stored_package, content_type: "audio")
  Fabricate(:queue_item, package: @package)
end

Given("an uploaded but not yet preserved Bentley audio artifact") do
  @package = Fabricate(:package, content_type: "audio")
  Fabricate(:queue_item, package: @package)
end

Given("an uploaded Bentley audio artifact that failed validation") do
  @package = Fabricate(:package, content_type: "audio")
  Fabricate(:queue_item, package: @package, status: 1)
end

Given("a Bentley audio artifact that has not been uploaded") do
  @package = Struct.new(:id, :bag_id).new("some_id", "some_bag_id")
end

Given("an uploaded Bentley audio artifact of any status") do
  @package = Fabricate(:stored_package, content_type: "audio")
end

Given("an audio deposit has been started") do
  @package = Fabricate(
    :package,
    bag_id: @bag.id,
    content_type: @bag.content_type,
    external_id: @bag.external_id
  )
end

