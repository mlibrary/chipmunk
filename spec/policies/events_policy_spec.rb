# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe EventsPolicy, type: :policy do
  let(:policy) { described_class.new(user, FakeCollection.new) }
  subject { described_class }

  context "as a user granted admin" do
    let(:user) { FakeUser.admin }

    it_allows :index?
    it_disallows :new?

    it { is_expected.to resolve(:all) }
  end

  context "as a content manager" do
    let(:user) do
      FakeUser.new.tap do |u|
        u.grant_role!('content_manager','audio')
        u.grant_role!('content_manager','video')
      end
    end

    it_allows :index?
    it_disallows :new?

    it { is_expected.to resolve(:audio,:video) }
  end

  context "as a viewer" do
    let(:user) { FakeUser.with_role('viewer','video') }

    it_allows :index?
    it_disallows :new?

    it { is_expected.to resolve(:video) }
  end

  context "as a user granted nothing" do
    let(:user) { FakeUser.new }

    it_disallows :new?, :index?

    it { is_expected.to resolve(:none) }
  end

  it_has_base_scope(Event.all)
end
