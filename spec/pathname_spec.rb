# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pathname do
  describe "#type (extension)" do
    it { expect(described_class.new("foo").type).to eql("application/octet-stream") }
    it { expect(described_class.new("foo.json").type).to eql("application/json") }
  end
end
