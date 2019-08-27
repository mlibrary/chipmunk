RSpec.describe Chipmunk::Validator::External do
  let(:validator) { described_class.new(command) }
  let(:bag) { double(:bag, valid?: true) }

  context "when the command succeeds" do
    let(:command) { "/bin/true" }

    it "is valid" do
      expect(validator.valid?(bag)).to be true
    end
  end

  context "when the command fails" do
    let(:command) { "ls /nondir" }

    it { expect(validator.valid?(bag)).to be false }
    it "reports the error" do
      expect(validator.errors(bag)).to include(a_string_matching(/cannot access/))
    end
  end

  context "when the bag is invalid" do
    let(:command) { "/bin/false" }
    let(:bag) { double(:bag, valid?: false) }

    it "skips this validator" do
      expect(validator.valid?(bag)).to be true
    end
  end

end
