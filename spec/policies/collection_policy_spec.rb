# frozen_string_literal: true

require "checkpoint_helper"
require "policy_errors"

RSpec.describe CollectionPolicy, :checkpoint_transaction, type: :policy do
  subject(:policy) { described_class.new(user, scope) }

  it_has_base_scope ApplicationRecord, :none

  let(:user)  { double(:user) }
  let(:scope) { double(:scope, all: []) }

  context "with a scope supplied" do
    let(:scope) { double(:scope, all: "all") }

    it "returns all of the supplied scope" do
      expect(policy.resolve).to eq "all"
    end
  end

  it_forbids :index?, :new?

  describe "authorize!" do
    [:index?, :new?].each do |action|
      it "raises an exception for #{action}" do
        expect { policy.authorize!(action) }.to raise_error(NotAuthorizedError)
      end
    end

    it "raises an exception for undefined action 'whatever?'" do
      expect { policy.authorize(:whatever?) }.to raise_error(NoMethodError)
    end
  end
end
