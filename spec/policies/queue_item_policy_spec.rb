# frozen_string_literal: true

RSpec.describe QueueItemPolicy do
  let(:resource) { double(:resource, user: double(:user)) }

  context "as an admin" do
    let(:user) { FakeUser.new(admin?: true) }

    it_allows :show?, :create?
    it_disallows :update?, :destroy?
  end

  context "as a persisted non-admin user" do
    let(:user) {  FakeUser.new(admin?: false) }

    context "with a resource owned by somebody else" do
      it_disallows :show?, :create?, :update?, :destroy?
    end

    context "with an owned resource" do
      let(:resource) { double(:resource, user: user) }

      it_allows :show?, :create?
      it_disallows :update?, :destroy?
    end
  end

  context "as an externally-identified user" do
    let(:user) { FakeUser.with_external_identity }

    it_disallows :show?, :create?, :update?, :destroy?
  end
end
