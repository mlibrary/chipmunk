# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe PackagesPolicy, type: :policy do
  subject { described_class }

  context "as an admin" do
    let(:user) { FakeUser.admin }

    it_allows :index?, :new?

    it { is_expected.to resolve(:all) }
  end

  context "as a content manager" do
    let(:user) { FakeUser.with_role('content_manager','audio') }

    it_allows :index?, :new?

    it { is_expected.to resolve(:audio) }
  end

  context "as a content manager for audio and video" do
    let(:user) do
      FakeUser.new.tap do |u|
        u.grant_role!('content_manager','audio')
        u.grant_role!('content_manager','video')
      end
    end

    it { is_expected.to resolve(:audio,:video) }
  end

  context "as a viewer" do
    let(:user) { FakeUser.with_role('viewer','digital') }

    it_allows :index?
    it_disallows :new?

    it { is_expected.to resolve(:digital) }
  end

  it_has_base_scope(Package.all)
end
