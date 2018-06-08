RSpec.describe PackageFileGetter do
  def fixture(*args)
    File.join(Rails.application.root, "spec", "support", "fixtures", *args)
  end

  let(:package) { double(:package, storage_location: fixture("test_bag"), stored?: true) }
  let(:service) { described_class.new(package) }

  describe "#files" do
    it "returns the list of files in the package's data directory" do
      expect(service.files).to contain_exactly(Pathname.new('samplefile'))
    end
  end

  describe "#initialize" do
    it "raises a RuntimeError if the package is not stored" do
      expect { described_class.new(double(:package, storage_location: nil, stored?: false)) }.to raise_error(RuntimeError)
    end
  end

  describe "#sendfile" do
    it "returns the full path for a given file in the package's data directory" do
      expect(service.sendfile('samplefile')).to eq(
        [ fixture('test_bag','data','samplefile'),
          type: "application/octet-stream" ])
    end

    it "raises a FileNotFound exception if a file is requested that isn't in the package's data directory" do
      expect { service.sendfile('nonexistent') }.to raise_error(FileNotFoundError)
    end

    it "raises a FileNotFound exception for traversal attempts" do
      expect { service.sendfile('../../test_bag/data/samplefile') }.to raise_error(FileNotFoundError)
    end
  end
end
