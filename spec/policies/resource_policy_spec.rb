# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe ResourcePolicy, :checkpoint_transaction, type: :policy do
  subject(:policy) { described_class.new(user, resource) }

  let(:resource) { double(:resource) }
  let(:user) { double(:user) }

  it_forbids :show?, :update?, :destroy?

  describe "authorize!" do
    [:show?, :update?, :destroy?].each do |action|
      it "raises an exception for #{action}" do
        expect { described_class.new(user, resource).authorize!(action) }.to raise_error(NotAuthorizedError)
      end
    end

    it "raises an exception for undefined action 'whatever?'" do
      expect { described_class.new(user, resource).authorize(:whatever?) }.to raise_error(NoMethodError)
    end
  end
end
