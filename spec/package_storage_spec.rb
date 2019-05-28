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

  # TODO: Set up a "test context" that has realistic, but test-focused
  # services registered. This will offload setup of the environment from
  # various tests. This may be as simple as registering test components over
  # top of those configured in the services initializer when Rails.env is
  # test. Alternatively, it may be that shared contexts would configure sets
  # of components and stub the services container to yield them based on
  # inclusion of specific contexts in tests that need them. In this group,
  # the volumes and volume manager can be considered environmental, while the
  # packages are scenario data.
  let(:bags)      { Volume.new(name: "bags", format: :bag, root_path: "/bags") }
  let(:zips)      { Volume.new(name: "zips", format: :zip, root_path: "/zips") }
  let(:manager)   { VolumeManager.new(volumes: [bags, zips]) }

  context "with two formats registered: bag and zip" do
    let(:storage)   { described_class.new(formats: formats, volume_manager: manager) }

    let(:formats)   { { bag: FakeBag, zip: FakeZip } }
    let(:bag)       { stored_package(format: "bag", storage_volume: "bags", storage_path: "/a-bag") }
    let(:zip)       { stored_package(format: "zip", storage_volume: "zips", storage_path: "/a-zip") }
    let(:transient) { unstored_package(format: "bag") }
    let(:tarball)   { stored_package(format: "tar-gz") }

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

    # A package may have a declared storage volume and path, but be of a format
    # for which we do not have a registered proxy class; raise exception if so.
    it "raises an error for an unsupported storage format" do
      expect { storage.for(tarball) }.to raise_error(Chipmunk::UnsupportedFormatError)
    end
  end

  def stored_package(format:, storage_volume: "test", storage_path: "/path")
    double(:package, stored?: true, format: format.to_sym, storage_volume: storage_volume, storage_path: storage_path)
  end

  def unstored_package(format:)
    double(:package, stored?: false, format: format)
  end
end
