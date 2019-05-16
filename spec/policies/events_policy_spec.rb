# frozen_string_literal: true

require "rails_helper"
require "support/helpers/policy_helpers"

RSpec.describe EventsPolicy do
  let(:policy) { described_class.new(user, FakeCollection.new) }

  context "as an admin" do
    let(:user) { FakeUser.new(admin?: true) }

    it_allows :index?
    it_disallows :new?

    it_resolves :all
  end

  context "as a persisted non-admin user" do
    let(:user) { FakeUser.new(admin?: false) }

    it_allows :index?
    it_disallows :new?

    it_resolves_owned
  end

  context "as an externally-identified user" do
    let(:user) { FakeUser.with_external_identity }

    it_disallows :index?, :new?
    it_resolves :none
  end

  it_has_base_scope(Event.all)
end
