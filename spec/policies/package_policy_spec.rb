# frozen_string_literal: true

require "checkpoint_helper"
require "ostruct"

RSpec.describe PackagePolicy, :checkpoint_transaction, type: :policy do
  subject { described_class.new(user, resource) }

  let(:resource) do
    double(:resource,
      user: double,
      resource_type: 'video',
      id: 1)
  end

  context "as an admin" do
    let(:user) { FakeUser.admin }

    it_allows :show?, :create?
    it_disallows :update?, :destroy?
  end

  context "as a content manager for the content type of the related package" do
    let(:user) { FakeUser.with_role('content_manager','video') }

    it_allows :show?, :create?
    it_disallows :update?, :destroy?
  end

  context "as a content manager for a content type not for the related packages" do
    let(:user) { FakeUser.with_role('content_manager','digital') }

    it_disallows :show?, :create?, :update?, :destroy?
  end

  context "as a viewer for the content type of the related package" do
    let(:user) { FakeUser.with_role('viewer','video') }

    it_allows :show?
    it_disallows :create?, :update?, :destroy?
  end

  context "as a viewer for the content type not for the related package" do
    let(:user) { FakeUser.with_role('viewer','digital') }

    it_disallows :show?, :create?, :update?, :destroy?
  end

  context "as a user granted nothing" do
    let(:user) {  FakeUser.new }

    it_disallows :show?, :create?, :update?, :destroy?
  end
end
