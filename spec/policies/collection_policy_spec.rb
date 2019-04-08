# frozen_string_literal: true

require "policy_errors"

RSpec.describe CollectionPolicy, type: :policy do
  let(:user) { double(:user) }

  describe "#base_scope" do
    it "returns an empty collection" do
      expect(described_class.new(user).base_scope).to eq(ApplicationRecord.none)
    end
  end

  describe "#resolve" do
    it "returns the original scope" do
      scope = double(:scope)
      expect(described_class.new(user, scope).resolve).to be(scope)
    end
  end

  it_disallows :index?, :new?

  describe "authorize!" do
    [:index?, :new?].each do |action|
      it "raises an exception for #{action}" do
        expect { described_class.new(user).authorize!(action) }.to raise_error(NotAuthorizedError)
      end
    end

    it "raises an exception for undefined action 'whatever?'" do
      expect { described_class.new(user).authorize(:whatever?) }.to raise_error(NoMethodError)
    end
  end
end
