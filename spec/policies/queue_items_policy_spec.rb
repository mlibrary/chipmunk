# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"

RSpec.describe QueueItemsPolicy do
  context "with an admin user" do
    let(:user) { double(:user, admin?: true) }

    it_allows :index?

    it "allows :create?" do
      expect(described_class.new(user).create?(double)).to be true
    end

    it_resolves :all
  end

  context "with a non-admin user with an api token" do
    let(:user) { double(:user, admin?: false, api_token: SecureRandom.uuid.delete("-")) }

    it_allows :index?

    context "when the request owner matches the user" do
      let(:request) { double(:request, user: user) }

      it "allows :create?" do
        expect(described_class.new(user).create?(request)).to be true
      end
    end

    context "when the request owner does not match the user" do
      let(:request) { double(:request, user: double) }

      it "does not allows :create?" do
        expect(described_class.new(user).create?(request)).to be false
      end
    end

    describe "#resolve" do
      it "returns queue items for owned packages only"
    end
  end

  context "with a user identifier by X-Remote-User" do
    #    let(:user) { ... }
    #    it_disallows(*collection_actions)
    #    it_resolves :none
  end

  it_has_base_scope(QueueItem.all)
end
