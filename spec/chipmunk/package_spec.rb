# frozen_string_literal: true

require "chipmunk/package"

RSpec.describe Chipmunk::Package do
  describe '#chipmunk_info' do
    subject(:package) { described_class.new }

    it 'is a hash' do
      expect(package.chipmunk_info).to be_a(Hash)
    end
  end
end
