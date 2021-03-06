# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe AuditPolicy, :checkpoint_transaction, type: :policy do
  subject(:policy) { described_class.new(user, resource) }

  let(:resource) { double(:resource, resource_type: "Audit", resource_id: 1) }

  context "as a user granted admin" do
    let(:user) { FakeUser.admin }

    it_allows :show?
    it_forbids :update?, :destroy?
  end

  context "as a content manager" do
    let(:user) { FakeUser.with_role("content_manager", "video") }

    it_forbids :show?, :update?, :destroy?
  end

  context "as a viewer" do
    let(:user) { FakeUser.with_role("viewer", "audio") }

    it_forbids :show?, :update?, :destroy?
  end

  context "as a user granted nothing" do
    let(:user) { FakeUser.new }

    it_forbids :show?, :update?, :destroy?
  end
end
