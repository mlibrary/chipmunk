# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe QueueItemsPolicy, type: :policy do
  context "as a user granted admin" do
    let(:user) { FakeUser.admin }

    it_allows :index?, :new?
    it_resolves :all
  end

  xcontext "as a persisted non-admin user" do
    let(:user) { FakeUser.new(admin?: false) }

    it_allows :index?, :new?
    it_resolves_owned
  end

  context "as an externally-identified user" do
    let(:user) { FakeUser.with_external_identity }
    let(:request) { double(:request, user: double) }

    it_disallows :index?, :new?
    it_resolves :none
  end

  it_has_base_scope(QueueItem.all)
end
