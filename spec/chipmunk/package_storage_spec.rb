# frozen_string_literal: true

RSpec.describe Chipmunk::PackageStorage do
  FakeBag = Struct.new(:storage_path) do
    def self.format
      "bag"
    end
  end

  FakeZip = Struct.new(:storage_path) do
    def self.format
      "zip"
    end
  end

  # TODO: Set up a "test context" that has realistic, but test-focused
  # services registered. This will offload setup of the environment from
  # various tests. This may be as simple as registering test components over
  # top of those configured in the services initializer when Rails.env is
  # test. Alternatively, it may be that shared contexts would configure sets
  # of components and stub the services container to yield them based on
  # inclusion of specific contexts in tests that need them. In this group,
  # the volumes and volume manager can be considered environmental, while the
  # packages are scenario data.
  let(:bags)      { Chipmunk::Volume.new(name: "bags", package_type: FakeBag, root_path: "/bags") }
  let(:zips)      { Chipmunk::Volume.new(name: "zips", package_type: FakeZip, root_path: "/zips") }

  context "with two formats registered: bag and zip" do
    let(:storage)   { described_class.new(volumes: [bags, zips]) }

    let(:formats)   { { bag: FakeBag, zip: FakeZip } }
    let(:bag)       { stored_package(format: "bag", storage_volume: "bags", storage_path: "/a-bag") }
    let(:zip)       { stored_package(format: "zip", storage_volume: "zips", storage_path: "/a-zip") }
    let(:transient) { unstored_package(format: "bag", id: "abcdef-123456") }
    let(:badvolume) { stored_package(format: "bag", storage_volume: "notfound") }

    let(:bag_proxy) { storage.for(bag) }
    let(:zip_proxy) { storage.for(zip) }

    it "creates a bag proxy for a bag package" do
      expect(bag_proxy).to be_a FakeBag
    end

    it "uses the bag volume for a bag" do
      expect(bag_proxy).to eq FakeBag.new("/bags/a-bag")
    end

    it "creates zip proxy for a zip package" do
      expect(zip_proxy).to be_a FakeZip
    end

    it "uses the zip volume for a zip" do
      expect(zip_proxy).to eq FakeZip.new("/zips/a-zip")
    end

    it "raises an error for unstored package" do
      expect { storage.for(transient) }.to raise_error(Chipmunk::PackageNotStoredError)
    end

    it "raises an error for a bad volume" do
      expect { storage.for(badvolume) }.to raise_error(Chipmunk::VolumeNotFoundError)
    end
  end

  describe "writing a package" do
    context "with a good bag" do
      subject(:storage) { described_class.new(volumes: [bags]) }

      let(:package)  { spy(:package, format: "bag", bag_id: "abcdef-123456") }
      let(:disk_bag) { double(:bag, path: "/uploaded/abcdef-123456") }

      before(:each) do
        allow(FileUtils).to receive(:mkdir_p).with("/bags/ab/cd/ef/abcdef-123456")
        allow(File).to receive(:rename).with("/uploaded/abcdef-123456", "/bags/ab/cd/ef/abcdef-123456")
      end

      it "ensures the destination directory exists" do
        expect(FileUtils).to receive(:mkdir_p)
        storage.write(package, disk_bag)
      end

      it "moves the source bag to the destination directory" do
        expect(File).to receive(:rename)
        storage.write(package, disk_bag)
      end

      it "sets the storage_volume" do
        expect(package).to receive(:storage_volume=).with("bags")
        storage.write(package, disk_bag)
      end

      it "sets the storage_path with three levels of hierarchy" do
        expect(package).to receive(:storage_path=).with("/ab/cd/ef/abcdef-123456")
        storage.write(package, disk_bag)
      end
    end

    context "with a badly identified bag (shorter than 6 chars)" do
      subject(:storage) { described_class.new(volumes: [bags]) }

      let(:package)  { double(:package, format: "bag", bag_id: "ab12") }
      let(:disk_bag) { double(:bag, path: "/uploaded/ab12") }

      it "raises an exception" do
        expect { storage.write(package, disk_bag) }.to raise_error RuntimeError
      end
    end

    context "with an unsupported archive format" do
      subject(:storage) { described_class.new(volumes: [bags]) }

      let(:package) { double(:package, format: "junk", bag_id: "id") }
      let(:archive) { double(:archive) }

      it "raises an Unsupported Format error" do
        expect { storage.write(package, archive) }.to raise_error(Chipmunk::UnsupportedFormatError, /junk/)
      end
    end
  end

  def stored_package(format:, storage_volume: "test", storage_path: "/path")
    double(:package, stored?: true, format: format.to_s, storage_volume: storage_volume, storage_path: storage_path)
  end

  def unstored_package(format:, id:)
    double(:package, stored?: false, format: format, bag_id: id)
  end
end
