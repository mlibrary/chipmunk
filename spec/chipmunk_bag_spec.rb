# frozen_string_literal: true

require "chipmunk_bag"
require "file_errors"

RSpec.describe ChipmunkBag do
  # set up data in safe area
  around(:each) do |example|
    Dir.mktmpdir do |tmp_dir|
      @empty_path = Pathname.new(tmp_dir)/"emptybag"
      FileUtils.mkdir_p @empty_path
      @stored_path = Pathname.new(tmp_dir)/"test_bag"
      FileUtils.cp_r(Rails.root/"spec"/"support"/"fixtures"/"test_bag", @stored_path)
      example.run
    end
  end

  let(:empty_path) { @empty_path }
  let(:stored_path) { @stored_path }
  let(:empty_bag) { described_class.new(@empty_path) }
  let(:stored_bag) { described_class.new(@stored_path) }


  describe "#data_file" do
    it "returns the full path for a given file in the data directory" do
      expect(stored_bag.data_file("samplefile").path).to eql(stored_path/"data"/"samplefile")
    end

    it "returns the appropriate mime type" do
      expect(stored_bag.data_file("samplefile").type).to eql("application/octet-stream")
    end

    it "raises a FileNotFound exception if a file is requested that isn't in the data directory" do
      expect { stored_bag.data_file("nonexistent") }.to raise_error(FileNotFoundError)
    end

    it "raises a FileNotFound exception for traversal attempts" do
      expect { stored_bag.data_file("../data/samplefile") }.to raise_error(FileNotFoundError)
    end
  end

  describe "#relative_data_files" do
    it "returns the list of files in the package's data directory" do
      expect(stored_bag.relative_data_files).to contain_exactly(Pathname.new("samplefile"))
    end
  end

  describe "#chipmunk_info" do
    context "with no chipmunk-info.txt" do
      it "returns an empty hash" do
        expect(empty_bag.chipmunk_info).to eq({})
      end
    end

    context "with contents in chipmunk-info.txt" do
      let(:metadata_url) { "http://whatever/foo.txt" }
      let(:metadata_file) { "whatever.txt" }

      let(:info_hash) do
        { "Metadata-URL"     => metadata_url,
          "Metadata-Tagfile" => metadata_file }
      end

      let(:info_txt) do
        <<~TXT
          Metadata-URL: #{metadata_url}
          Metadata-Tagfile: #{metadata_file}
        TXT
      end

      before(:each) { File.write(empty_path/"chipmunk-info.txt", info_txt) }

      it "returns a hash of its contents" do
        expect(empty_bag.chipmunk_info).to eq(info_hash)
      end
    end
  end
end
