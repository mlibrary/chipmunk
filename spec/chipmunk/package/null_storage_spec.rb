# frozen_string_literal: true

require "chipmunk/package/null_storage"

RSpec.describe Chipmunk::Package::NullStorage do
  describe '#get' do
    subject(:storage) { described_class.new }
    let(:package) { double(:package) }

    it 'returns nil' do
      expect(storage.get('id')).to be_nil
    end

    it 'says nothing exists' do
      expect(storage.exists?('id')).to be false
    end

    it 'cannot save' do
      expect { storage.save(package) }.to raise_error NotImplementedError
    end
  end
end
