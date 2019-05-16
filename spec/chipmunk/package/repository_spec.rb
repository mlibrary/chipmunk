# frozen_string_literal: true

require "chipmunk/package/repository"
require "chipmunk/volume"
require "chipmunk/errors"

RSpec.describe Chipmunk::Package::Repository do
  describe 'registering storage adapters' do
    let(:storage)  { double(:storage) }
    subject(:repo) { described_class.new }

    ["some_volume", :some_volume, Chipmunk::Volume.new("some_volume")].each do |volume|
      it "supports a registered volume (as a #{volume.class})" do
        repo.register volume, storage
        supported = repo.supports?(volume)
        expect(supported).to be true
      end
      it "does not support a unregistered volume (as a #{volume.class})" do
        supported = repo.supports?(volume)
        expect(supported).to be false
      end
    end
  end

  describe 'saving a package' do
    let(:package)  { double(:package) }
    let(:storage)  { double(:storage, save: nil) }
    subject(:repo) { described_class.new }

    before do
      repo.register(:pkg, storage)
    end

    it "saves the thing" do
      expect(storage).to receive(:save).with(package)
      repo.save(volume: :pkg, package: package)
    end

    context 'with an unsupported volume' do
      it 'raises an Unsupportedvolume' do
        expect do
          repo.find(volume: :other, id: 'id')
        end.to raise_error(Chipmunk::UnsupportedVolumeError)
      end
    end
  end

  describe 'finding a package' do
    let(:package)  { double(:package) }
    let(:storage)  { double(:storage, get: nil) }
    subject(:repo) { described_class.new }

    before do
      repo.register(:pkg, storage)
    end

    context 'when it exists in storage' do
      before(:each) do
        allow(storage).to receive(:get).with('id').and_return(package)
        allow(storage).to receive(:exists?).with('id').and_return(true)
      end
      it "#exists? is true" do
        expect(repo.exists?(volume: :pkg, id: 'id')).to be true
      end
      it 'retrieves the package' do
        found = repo.find(volume: :pkg, id: 'id')
        expect(found).to be package
      end
    end

    context 'when it does not exist in storage' do
      before(:each) do
        allow(storage).to receive(:get).with('id').and_return(package)
        allow(storage).to receive(:exists?).with('id').and_return(false)
      end
      it "#exists? is false" do
        expect(repo.exists?(volume: :pkg, id: 'id')).to be false
      end
      it 'raises a PackageNotFoundError' do
        expect do
          repo.find(volume: :pkg, id: 'missing')
        end.to raise_error(Chipmunk::PackageNotFoundError)
      end
    end

    context 'with an unsupported volume' do
      it 'raises an Unsupportedvolume' do
        expect do
          repo.find(volume: :other, id: 'id')
        end.to raise_error(Chipmunk::UnsupportedVolumeError)
      end
    end
  end
end
