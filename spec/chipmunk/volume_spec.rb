# frozen_string_literal: true

require "chipmunk/volume"

RSpec.describe Chipmunk::Volume do
  let(:name) { "foo" }
  let(:volume) { described_class.new(name) }
  describe "#to_s" do
    it { expect(volume.to_s).to eql(name) }
  end

  it "can be created from a Volume" do
    other = described_class.new(volume)
    expect(other).to eql(volume)
  end

  it "can be created from a Symbol" do
    other = described_class.new(name.to_sym)
    expect(other).to eql(volume)
  end
end
