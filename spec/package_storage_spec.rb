# frozen_string_literal: true

RSpec.describe PackageStorage do
  FakeBag = Struct.new(:storage_location) do
    def format
      "bag"
    end
  end

  FakeZip = Struct.new(:storage_location) do
    def format
      "zip"
    end
  end

  context "with two formats registered: bag and zip" do
    let(:storage)   { described_class.new(formats: { bag: FakeBag, zip: FakeZip }) }

    let(:bag)       { stored_package(format: "bag", storage_location: "/somewhere") }
    let(:zip)       { stored_package(format: "zip") }
    let(:transient) { unstored_package(format: "bag") }
    let(:tarball)   { stored_package(format: "tar-gz") }

    let(:bag_proxy) { storage.for(bag) }
    let(:zip_proxy) { storage.for(zip) }

    it "uses the correct storage location" do
      expect(bag_proxy).to eq FakeBag.new("/somewhere")
    end

    it "uses bag storage for the bag package" do
      expect(bag_proxy).to be_a FakeBag
    end

    it "uses zip storage for the zip package" do
      expect(zip_proxy).to be_a FakeZip
    end

    it "raises an error for unstored package" do
      expect { storage.for(transient) }.to raise_error(Chipmunk::PackageNotStoredError)
    end

    it "raises an error for an unsupported storage format" do
      expect { storage.for(tarball) }.to raise_error(Chipmunk::UnsupportedFormatError)
    end
  end

  def stored_package(format:, storage_location: "/path")
    double(:package, stored?: true, format: format, storage_location: storage_location)
  end

  def unstored_package(format:, storage_location: "/path")
    double(:package, stored?: false, format: format, storage_location: storage_location)
  end
end
