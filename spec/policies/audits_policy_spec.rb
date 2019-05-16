# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe AuditsPolicy, :checkpoint_transaction, type: :policy  do
  subject { described_class.new(user, FakeCollection.new) }

  context "as a user granted admin" do
    let(:user) { FakeUser.admin() }

    it_allows :index?, :new?
    it_resolves :all
  end

  context "as a content manager" do
    let(:user) { FakeUser.with_role('content_manager','audio') }

    it_disallows :index?, :new?
    it_resolves :none
  end

  context "as a viewer" do
    let(:user) { FakeUser.with_role('content_manager','digital') }

    it_disallows :index?, :new?
    it_resolves :none
  end

  context "as a user granted nothing" do
    let(:user) { FakeUser.new() }

    it_disallows :index?, :new?
    it_resolves :none
  end

  it_has_base_scope(Audit.all)
end
