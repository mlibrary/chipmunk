# frozen_string_literal: true

require "pathname"

RSpec.describe Volume do
  subject(:volume) { described_class.new(name: name, format: format, root_path: root_path) }

  context "when given valid attributes" do
    let(:name)      { "vol" }
    let(:format)    { :fmt }
    let(:root_path) { "/path" }

    it "has the correct name" do
      expect(volume.name).to eq "vol"
    end

    it "has the correct format" do
      expect(volume.format).to eq :fmt
    end

    it "has the correct path" do
      expect(volume.root_path).to eq Pathname("/path")
    end
  end

  context "when given a blank name" do
    let(:name)      { "" }
    let(:format)    { :fmt }
    let(:root_path) { "/path" }

    it "raises an argument error that the name must not be blank" do
      expect { volume }.to raise_error(ArgumentError, /name.*blank/)
    end
  end

  context "when given a blank format" do
    let(:name)      { "vol" }
    let(:format)    { "" }
    let(:root_path) { "/path" }

    it "raises an argument error that the format must not be blank" do
      expect { volume }.to raise_error(ArgumentError, /format.*blank/)
    end
  end

  context "when given a relative path" do
    let(:name)      { "vol" }
    let(:format)    { :fmt }
    let(:root_path) { "relative/path" }

    it "raises an argument error that path must be absolute" do
      expect { volume }.to raise_error(ArgumentError, /path.*absolute/)
    end
  end
end
