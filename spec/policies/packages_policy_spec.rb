# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe PackagesPolicy, type: :policy do
  context "as an admin" do
    let(:user) { FakeUser.admin }

    it_allows :index?, :new?
    it_resolves :all
  end

  context "as a content manager" do
    let(:user) { FakeUser.with_role('content_manager','audio') }

    it_allows :index?, :new?

    xit "resolves audio packages"
  end

  xcontext "as a content manager for audio and video" do
    # TODO: grant both audio & video
    let(:user) {}

    xit "resolves audio and video packages"
  end

  context "as a viewer" do
    let(:user) { FakeUser.with_role('viewer','digital') }

    it_allows :index?
    it_disallows :new?

    xit "resolves digital packages"
  end

  it_has_base_scope(Package.all)
end
