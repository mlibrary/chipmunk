# frozen_string_literal: true

Given("I have a Bentley audio bag to deposit") do
  @bag = Chipmunk::Bag.new(fixture("test_bag"))
end

Given("I have a malformed Bentley audio bag to deposit") do
  @bag = Chipmunk::Bag.new(fixture("bad_test_bag"))
end
