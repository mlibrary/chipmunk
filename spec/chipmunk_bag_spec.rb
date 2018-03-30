# frozen_string_literal: true

require "spec_helper"
require "chipmunk_bag"

def make_bag
  @bag = ChipmunkBag.new bag_path
end

RSpec.describe ChipmunkBag do
  # set up data in safe area
  around(:each) do |example|
    Dir.mktmpdir do |tmp_dir|
      @tmp_dir = tmp_dir
      @bag_path = File.join(tmp_dir, "testbag")
      example.run
    end
  end

  let(:bag_data) { File.join(@bag_path, "data") }
  let(:chipmunk_info) { File.join(@bag_path, "chipmunk-info.txt") }

  subject { ChipmunkBag.new(@bag_path) }

  describe "#chipmunk_info" do
    context "with no chipmunk-info.txt" do
      it "returns an empty hash" do
        expect(subject.chipmunk_info).to eq({})
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

      before(:each) do
        FileUtils.mkdir_p(@bag_path)
        File.write(chipmunk_info, info_txt)
      end

      it "returns a hash of its contents" do
        expect(subject.chipmunk_info).to eq(info_hash)
      end
    end
  end
end
