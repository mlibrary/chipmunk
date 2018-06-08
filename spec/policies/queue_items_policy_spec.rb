# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"

RSpec.describe QueueItemsPolicy do
  context "as an admin" do
    let(:user) { FakeUser.new(admin?: true) }

    it_allows :index?

    it "allows :create?" do
      expect(described_class.new(user).create?(double)).to be true
    end

    it_resolves :all
  end

  context "as a persisted non-admin user" do
    let(:user) { FakeUser.new(admin?: false) }

    it_allows :index?

    context "when the request owner matches the user" do
      let(:request) { double(:request, user: user) }

      it "allows :create?" do
        expect(described_class.new(user).create?(request)).to be true
      end
    end

    context "when the request owner does not match the user" do
      let(:request) { double(:request, user: double) }

      it "does not allows :create?" do
        expect(described_class.new(user).create?(request)).to be false
      end
    end

    it_resolves_owned
  end

  context "as an externally-identified user" do
    let(:user) { FakeUser.with_external_identity }
    let(:request) { double(:request, user: double) }

    it_disallows :index?
    it_resolves :none

    it "does not allows :create?" do
      expect(described_class.new(user).create?(request)).to be false
    end
  end

  it_has_base_scope(QueueItem.all)
end
