# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe QueueItemsPolicy, :checkpoint_transaction, type: :policy do
  context "as a user granted admin" do
    let(:user) { FakeUser.admin }

    it_allows :index?, :new?

    it { expect(described_class).to resolve(:all) }
  end

  context "as a content manager" do
    let(:user) { FakeUser.with_role('content_manager','digital') }

    it_allows :index?, :new?

    it { expect(described_class).to resolve(:digital) }
  end

  context "as a viewer for multiple content types" do
    let(:user) do
      FakeUser.new.tap do |u|
        u.grant_role!('viewer','video')
        u.grant_role!('viewer','digital')
      end
    end

    it_allows :index?
    it_disallows :new?

    it { expect(described_class).to resolve(:video,:digital) }
  end

  context "as a user granted nothing" do
    let(:user) { FakeUser.new }

    it_disallows :index?, :new?

    it { expect(described_class).to resolve(:none) }
  end

  it_has_base_scope(QueueItem.all)
end
