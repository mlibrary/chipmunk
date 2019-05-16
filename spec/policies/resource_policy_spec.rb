# frozen_string_literal: true

require "rails_helper"
require "support/helpers/policy_helpers"

RSpec.describe ResourcePolicy do
  let(:resource) { double(:resource) }
  let(:user) { double(:user) }

  it_disallows :show?, :update?, :destroy?

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
