RSpec.describe Chipmunk::Validator::BaggerProfile do
  let(:validator) { described_class.new(profile) }
  let(:bag) { double(:bag, bag_info: { "Baz" => "quux" }) }
  let(:profile) do
    Chipmunk::Bag::Profile.new(
      "file://" + Rails.root.join("spec", "support", "fixtures", "test-profile.json").to_s
    )
  end

  it "tests the bag against the profile" do
    expect(validator.errors(bag)).to include(a_string_matching(/Foo.*required/))
  end
end
