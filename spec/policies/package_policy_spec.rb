# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"

RSpec.describe PackagePolicy do
  let(:resource) { double(:resource, user: double) }

  context "as an admin user" do
    let(:user) { double(:user, admin?: true) }

    it_allows :show?
    it_disallows :update?, :destroy?
  end

  context "as a non-admin user with an api token" do
    let(:user) {  double(:user, admin?: false, api_token: SecureRandom.uuid.delete("-")) }

    context "with an owned resource" do
      let(:resource) { double(:resource, user: user) }

      it_allows :show?
      it_disallows :update?, :destroy?
    end

    context "with an unowned resource" do
      it_disallows(*resource_actions)
    end
  end

  context "as a user identified via X-Remote-User" do
    # let(:user) { ... }
    # it_disallows(*resource_actions)
  end
end
