# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe PackagesPolicy, :checkpoint_transaction, type: :policy do
  subject(:policy) { described_class.new(user, scope) }

  let(:user)  { FakeUser.new }
  let(:scope) { FakeCollection.new(resource_types: ["digital", "audio", "video"]) }

  it_has_base_scope Package, :all

  context "as an admin" do
    let(:user) { FakeUser.admin }

    it_allows :index?, :new?

    it_resolves :all
  end

  context "as a content manager" do
    let(:user) { FakeUser.with_role("content_manager", "audio") }

    it_allows :index?, :new?

    it_resolves :audio
  end

  context "as a content manager for audio and video" do
    let(:user) do
      FakeUser.new.tap do |u|
        u.grant_role!("content_manager", "audio")
        u.grant_role!("content_manager", "video")
      end
    end

    it_resolves :audio, :video
  end

  context "as a viewer" do
    let(:user) { FakeUser.with_role("viewer", "digital") }

    it_allows :index?
    it_forbids :new?

    it_resolves :digital
  end
end
