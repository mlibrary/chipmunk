# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"

RSpec.describe ResourcePolicy do
  let(:resource) { double(:resource) }
  let(:user) { double(:user) }

  it_disallows(*resource_actions)

  describe "authorize!" do
    resource_actions.each do |action|
      it "raises an exception for #{action}" do
        expect { described_class.new(user, resource).authorize!(action) }.to raise_error(NotAuthorizedError)
      end
    end

    it "raises an exception for undefined action 'whatever?'" do
      expect { described_class.new(user, resource).authorize(:whatever?) }.to raise_error(NoMethodError)
    end
  end
end
