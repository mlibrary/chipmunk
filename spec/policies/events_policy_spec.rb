# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe EventsPolicy, type: :policy do
  let(:policy) { described_class.new(user, FakeCollection.new) }

  context "as a user granted admin" do
    let(:user) { FakeUser.admin }

    it_allows :index?
    it_disallows :new?

    it_resolves :all
  end

  context "as a collection manager" do
    let(:user) { FakeUser.with_role('content_manager','audio') }

    it_allows :index?
    it_disallows :new?

    it "resolves all objects of the type the user manages"
  end

  xcontext "as a viewer" do
    let(:user) { FakeUser.with_role('viewer','video') }

    it_allows :index?
    it_disallows :new?

    it "resolves all objects of the type the user is granted"
  end

  context "as a user granted nothing" do
    let(:user) { FakeUser.new }

    it_disallows :new?, :index?
    it_resolves :none
  end

  it_has_base_scope(Event.all)
end
