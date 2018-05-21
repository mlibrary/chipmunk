# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"

RSpec.describe AuditsPolicy do
  context "as an admin" do
    let(:user) { double(:user, admin?: true) }

    it_allows(*collection_actions)
    it_resolves(:all)
  end

  context "as a non-admin user with an api token" do
    let(:user) { double(:user, admin?: false, api_token: SecureRandom.uuid.delete("-")) }

    it_disallows(*collection_actions)
    it_resolves(:none)
  end

  context "as a user identified via X-Remote-User" do
    # let(:user) { user = double(:user, admin?: false, api_token: nil, FIXME identify remote user) }
    # it_disallows(*collection_actions)
    # it_resolves(:none)
  end

  it_has_base_scope(Audit.all)
end
