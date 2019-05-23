# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe QueueItemsPolicy, :checkpoint_transaction, type: :policy do
  subject(:policy) { described_class.new(user, scope, packages_policy: packages_policy) }

  it_has_base_scope QueueItem, :all

  let(:user)  { FakeUser.new }
  let(:scope) { FakeCollection.new }
  let(:packages_policy) { double }

  context "when the PackagesPolicy allows index?" do
    let(:packages_policy) { double("PackagesPolicy", index?: true) }

    it_allows :index?
  end

  context "when the PackagesPolicy allows new?" do
    let(:packages_policy) { double("PackagesPolicy", new?: true) }

    it_allows :new?
  end

  context "when the PackagesPolicy forbids index?" do
    let(:packages_policy) { double("PackagesPolicy", index?: false) }

    it_forbids :index?
  end

  context "when the PackagesPolicy forbids new?" do
    let(:packages_policy) { double("PackagesPolicy", new?: false) }

    it_forbids :new?
  end

  describe "#resolve" do
    let(:packages_policy) { double("PackagesPolicy", resolve: ["dummy-relation"]) }

    it "scopes events to corresponding, visible packages" do
      expect(policy).to resolve([:packages, ["dummy-relation"]])
    end
  end
end
