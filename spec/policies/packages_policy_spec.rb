# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"

RSpec.describe PackagesPolicy do
  context "with an admin user" do
    let(:user) { double(:user, admin?: true) }

    it_allows(*collection_actions)
    it_resolves :all
  end

  context "with a non-admin user with an api token" do
    let(:user) { double(:user, admin?: false, api_token: SecureRandom.uuid.delete("-")) }

    it_allows(*collection_actions)

    describe "#resolve" do
      it "returns owned packages only"
    end
  end

  context "with a user identifier by X-Remote-User" do
    #    let(:user) { ... }
    #    it_disallows(*collection_actions)
    #    it_resolves :none
  end

  it_has_base_scope(Package.all)
end
