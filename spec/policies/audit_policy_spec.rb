# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"

RSpec.describe AuditPolicy do
  let(:resource) { double(:resource) }

  context "with an admin" do
    let(:user) { double(:user, admin?: true) }

    it_allows :show?
    it_disallows :update?, :destroy?
  end

  context "with a non-admin user with an api token" do
    let(:user) { double(:user, admin?: false, api_token: SecureRandom.uuid.delete("-")) }

    it_disallows(*resource_actions)
  end

  context "with a user identified by X-Remote-User" do
    # let(:user) { ... }
    # it_disallows(*resource_actions)
  end
end
