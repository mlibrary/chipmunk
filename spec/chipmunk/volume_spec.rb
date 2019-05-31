# frozen_string_literal: true

require "pathname"

RSpec.describe Chipmunk::Volume do
  subject(:volume) { described_class.new(name: name, package_type: package_type, root_path: root_path) }

  context "when given valid attributes" do
    let(:name)         { "vol" }
    let(:proxy)        { double(:storage_proxy) }
    let(:package_type) { double("SomeFormat", new: proxy, format: "some-pkg") }
    let(:root_path)    { "/path" }

    it "has the correct name" do
      expect(volume.name).to eq "vol"
    end

    it "has the correct format" do
      expect(volume.format).to eq "some-pkg"
    end

    it "has the correct root path" do
      expect(volume.root_path).to eq Pathname("/path")
    end

    it "expands relative paths correctly" do
      expect(volume.expand("foo/bar")).to eq "/path/foo/bar"
    end

    it "expands absolute paths correctly" do
      expect(volume.expand("/foo/bar")).to eq "/path/foo/bar"
    end

    it "creates a storage proxy for a path" do
      expect(volume.get("/foo/bar")).to eq proxy
    end

    describe "checking package existence" do
      before(:each) do
        allow(File).to receive(:exist?).and_return false
        allow(File).to receive(:exist?).with("/path/existent").and_return true
      end

      it "reports existent packages as included" do
        expect(volume.include?("/existent")).to eq true
      end

      it "reports nonexistent packages as missing" do
        expect(volume.include?("/nonexistent")).to eq false
      end
    end
  end

  context "when given a blank name" do
    let(:name)         { "" }
    let(:package_type) { double("SomeFormat", new: nil, format: "some-pkg") }
    let(:root_path)    { "/path" }

    it "raises an argument error that the name must not be blank" do
      expect { volume }.to raise_error(ArgumentError, /name.*blank/)
    end
  end

  context "when given a relative path" do
    let(:name)         { "vol" }
    let(:package_type) { double("SomeFormat", new: nil, format: "some-pkg") }
    let(:root_path)    { "relative/path" }

    it "raises an argument error that path must be absolute" do
      expect { volume }.to raise_error(ArgumentError, /path.*absolute/)
    end
  end
end
