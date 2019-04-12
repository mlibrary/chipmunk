# frozen_string_literal: true

RSpec.describe BagRepository do
  FakeBag = Struct.new(:storage_location)

  let(:location) { double(:location) }
  subject { described_class.new(FakeBag) }

  describe "#for" do
    context "given a stored package" do
      let(:package) { double(:package, stored?: true, storage_location: location) }
      it "returns the package's bag" do
        expect(subject.for(package)).to eql(FakeBag.new(location))
      end
    end

    context "given an un-stored package" do
      let(:package) { double(:package, stored?: false, storage_location: location) }
      it "raises a RuntimeError" do
        expect { subject.for(package) }.to raise_error(RuntimeError)
      end
    end
  end

end
