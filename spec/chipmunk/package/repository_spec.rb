# frozen_string_literal: true

RSpec.describe Chipmunk::Package::Repository do
  describe 'registering storage adapters' do
    let(:storage)  { double(:storage) }
    subject(:repo) { described_class.new }

    it 'supports a registered format' do
      repo.register :format, storage
      supported = repo.supports?(:format)
      expect(supported).to be true
    end

    it 'does not support a unregistered format' do
      supported = repo.supports?(:format)
      expect(supported).to be false
    end
  end

  describe 'finding a package' do
    let(:package)  { double(:package) }
    let(:storage)  { double(:storage, get: nil) }
    subject(:repo) { described_class.new }

    before do
      allow(storage).to receive(:get).with('id').and_return(package)
      repo.register(:pkg, storage)
    end

    context 'when it exists in storage' do
      it 'retrieves the package' do
        found = repo.find(format: :pkg, id: 'id')
        expect(found).to be package
      end
    end

    context 'when it does not exist in storage' do
      it 'raises a PackageNotFoundError' do
        expect do
          repo.find(format: :pkg, id: 'missing')
        end.to raise_error(Chipmunk::PackageNotFoundError)
      end
    end

    context 'with an unsupported format' do
      it 'raises an UnsupportedFormatError' do
        expect do
          repo.find(format: :other, id: 'id')
        end.to raise_error(Chipmunk::UnsupportedFormatError)
      end
    end
  end
end
