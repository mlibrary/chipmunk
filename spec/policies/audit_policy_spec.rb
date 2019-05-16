# frozen_string_literal: true

require "rails_helper"
require "support/helpers/policy_helpers"

RSpec.describe AuditPolicy do
  let(:resource) { double(:resource) }

  context "as an admin" do
    let(:user) { FakeUser.new(admin?: true) }

    it_allows :show?
    it_disallows :update?, :destroy?
  end

  context "as a persisted non-admin user" do
    let(:user) { FakeUser.new(admin?: false) }

    it_disallows :show?, :update?, :destroy?
  end

  context "as an externally-identified user" do
    let(:user) { FakeUser.with_external_identity }

    it_disallows :show?, :update?, :destroy?
  end
end
