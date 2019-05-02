# frozen_string_literal: true

# TODO: Extract to shared example for the Storage interface
RSpec.describe Chipmunk::Bag::DiskStorage do
  around(:each) do |example|
    Dir.mktmpdir do |tmp_dir|
      @root_path = tmp_dir
      @empty_path = Pathname.new(tmp_dir)/"empty_bag"
      FileUtils.mkdir_p(@empty_path)
      @stored_path = Pathname.new(tmp_dir)/"test_bag"
      FileUtils.cp_r(RSPEC_ROOT.join("support/fixtures/test_bag"), @root_path)
      example.run
    end
  end

  let(:root_path) { Pathname.new(@root_path) }
  subject(:storage) { described_class.new(@root_path) }

  describe "#get" do
    context "with an unstored ID" do
      it "raises BagNotFoundError" do
        expect do
          storage.get('missing')
        end.to raise_error(Chipmunk::BagNotFoundError)
      end
    end

    context "with a stored ID" do
      it "returns a Bag" do
        expect(storage.get('test_bag')).to be_a(Chipmunk::Bag)
      end

      it "makes a bag with matching ID" do
        bag = storage.get('test_bag')
        expect(bag.id).to eq 'test_bag'
      end

      it "binds the bag to itself" do
        expect(Chipmunk::Bag).to receive(:new).with(id: 'test_bag', storage: storage)
        storage.get('test_bag')
      end
    end
  end

  describe "#root_path" do
    it "gives the full path to the storage root" do
      expect(storage.root_path).to eq root_path
    end
  end
end
