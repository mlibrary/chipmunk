# frozen_string_literal: true

RSpec.describe VolumeManager do
  subject(:manager) { described_class.new(volumes: volumes) }

  let(:volume_one)  { Volume.new(name: "one", format: :fmt, root_path: "/one") }
  let(:volume_two)  { Volume.new(name: "two", format: :fmt, root_path: "/two") }
  let(:dupe_volume) { Volume.new(name: "two", format: :fmt, root_path: "/dupe") }

  context "when given one volume" do
    let(:volumes) { [volume_one] }

    it "can find the volume by name" do
      expect(manager.find("one")).to eq volume_one
    end

    it "raises an error for an unregistered name" do
      expect { manager.find("two") }.to raise_error(Chipmunk::VolumeNotFoundError, /two/)
    end
  end

  context "when given two volumes" do
    let(:volumes) { [volume_one, volume_two] }

    it "can find volume one" do
      expect(manager.find("one")).to eq volume_one
    end

    it "can find volume two" do
      expect(manager.find("two")).to eq volume_two
    end
  end

  context "when given two volumes with the same name" do
    let(:volumes) { [volume_two, dupe_volume] }

    it "finds the last volume with that name" do
      expect(manager.find("two")).to eq dupe_volume
    end
  end
end
