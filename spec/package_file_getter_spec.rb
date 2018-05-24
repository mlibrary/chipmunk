RSpec.describe PackageFileGetter do
  def fixture(*args)
    File.join(Rails.application.root, "spec", "support", "fixtures", *args)
  end

  let(:package) { double(:package, storage_location: fixture("test_bag")) }
  let(:service) { described_class.new(package) }

  describe "#files" do
    it "returns the list of files in the package's data directory" do
      expect(service.files).to contain_exactly(Pathname.new('samplefile'))
    end
  end

  describe "#sendfile" do
    it "returns the appropriate X-Sendfile headers for a given file in the package's data directory" do
      expect(service.sendfile('samplefile')).to eq(
        { "X-Sendfile" => fixture('test_bag','data','samplefile'),
          "Content-Type" => "application/octet-stream",
          "Content-Disposition" => "attachment; filename=\"samplefile\"" })
    end

    it "raises a FileNotFound exception if a file is requested that isn't in the package's data directory" do
      expect { service.sendfile('nonexistent') }.to raise_error(FileNotFoundError)
    end

    it "raises a FileNotFound exception for traversal attempts" do
      expect { service.sendfile('../../test_bag/data/samplefile') }.to raise_error(FileNotFoundError)
    end

    context "with mocked bag" do
      let(:bag) { double(:bag, data_dir: '/foo', bag_files: ['/foo/samplefile.jpg'] ) }
      let(:storage) { double(:storage, new: bag) }
      let(:service) { described_class.new(package, storage: storage) }

      it "returns Content-type: image/jpeg for an (apparent) jpeg file" do
        expect(service.sendfile('samplefile.jpg')["Content-Type"]).to eq("image/jpeg")
      end
    end
  end
end
