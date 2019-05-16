# frozen_string_literal: true

require "chipmunk/bag/disk_storage"
require "chipmunk/errors"
require "fileutils"
require "pathname"

# TODO: Extract to shared example for the Storage interface
RSpec.describe Chipmunk::Bag::DiskStorage do
  around(:each) do |example|
    Dir.mktmpdir do |tmp_dir|
      @id = "9674434a-ab0b-4ffd-beb3-9addaad9c329"
      @root_path = Pathname.new(tmp_dir)
      @stored_path = @root_path/"96/74/43/9674434a-ab0b-4ffd-beb3-9addaad9c329"
      FileUtils.mkdir_p @stored_path
      FileUtils.cp_r(RSPEC_ROOT/"support/fixtures/test_bag", @stored_path)
      example.run
    end
  end

  let(:id) { @id }
  let(:root_path) { @root_path }
  let(:dest_factory) { double(:dest_factory) }
  subject(:storage) { described_class.new(@root_path, dest_factory: dest_factory) }

  describe "#exists?" do
    context "with an unstored ID" do
      it "is false" do
        expect(storage.exists?('missing')).to be false
      end
    end
    context "with a ID too short for the path strategy" do
      it "is false" do
        expect(storage.exists?('1234')).to be false
      end
    end
    context "with a stored ID" do
      it "is true" do
        expect(storage.exists?(id)).to be true
      end
    end
  end

  describe "#save" do
    let(:new_id) { "1eb68516-5fd7-48cf-9d9c-d1bb89560560" }
    let(:new_path) { root_path/"1e"/"b6"/"85"/new_id }
    let(:bag) { double(:bag, id: new_id, copy: nil) }
    let(:dest) { double(:dest) }

    before(:each) do
      allow(dest_factory).to receive(:new).with(new_path).and_return(dest)
    end

    it "saves the bag to disk" do
      expect(bag).to receive(:copy).with(dest)
      storage.save(bag)
    end
  end

  describe "#get" do
    context "with an unstored ID" do
      it "raises BagNotFoundError" do
        expect do
          storage.get('missing')
        end.to raise_error(Chipmunk::BagNotFoundError)
      end
    end

    context "with a ID too short for the path strategy" do
      it "raises BagNotFoundError" do
        expect do
          storage.get('1234')
        end.to raise_error(Chipmunk::BagNotFoundError)
      end
    end

    context "with a stored ID" do
      it "returns a Bag" do
        expect(storage.get(id)).to be_a(Chipmunk::Bag)
      end

      it "makes a bag with matching ID" do
        bag = storage.get(id)
        expect(bag.id).to eq id
      end
    end
  end

  describe "#root_path" do
    it "gives the full path to the storage root" do
      expect(storage.root_path).to eq root_path
    end
  end
end
