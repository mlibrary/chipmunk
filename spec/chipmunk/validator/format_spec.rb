RSpec.describe Chipmunk::Validator::Format do
  let(:format) { "someformat" }
  let(:validator) { described_class.new(format) }

  context "when the format matches" do
    let(:sip) { double(:sip, format: format) }
    it "is valid" do
      expect(validator.valid?(sip)).to be true
    end
  end

  context "when the format diverges" do
    let(:sip) { double(:sip, identifier: "someid", format: "sandwich") }

    it "reports the error" do
      expect(validator.errors(sip))
        .to include("SIP someid has invalid format: sandwich")
    end
  end
end
