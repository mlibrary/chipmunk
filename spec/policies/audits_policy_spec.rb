# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe AuditsPolicy, :checkpoint_transaction, type: :policy do
  subject(:policy) { described_class.new(user, scope) }

  it_has_base_scope Audit, :all

  let(:user)  { FakeUser.new }
  let(:scope) { FakeCollection.new(resource_types: ["Audit"]) }

  context "as a user granted admin" do
    let(:user) { FakeUser.admin }

    it_allows :index?, :new?
    it_resolves :all
  end

  context "as a content manager" do
    let(:user) { FakeUser.with_role("content_manager", "audio") }

    it_forbids :index?, :new?
    it_resolves :none
  end

  context "as a viewer" do
    let(:user) { FakeUser.with_role("content_manager", "digital") }

    it_forbids :index?, :new?
    it_resolves :none
  end

  context "as a user granted nothing" do
    let(:user) { FakeUser.new }

    it_forbids :index?, :new?
    it_resolves :none
  end
end
