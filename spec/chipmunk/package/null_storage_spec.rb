# frozen_string_literal: true

RSpec.describe Chipmunk::Package::NullStorage do
  describe '#get' do
    subject(:storage) { described_class.new }

    it 'returns nil' do
      expect(storage.get('id')).to be_nil
    end
  end
end
