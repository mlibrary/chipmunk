# frozen_string_literal: true

require "checkpoint_helper"

RSpec.describe EventsPolicy, :checkpoint_transaction, type: :policy do
  subject { described_class.new(user, scope, packages_policy: packages_policy) }

  it_has_base_scope Event, :all

  let(:user)  { FakeUser.new }
  let(:scope) { FakeCollection.new }
  let(:packages_policy) { double }

  context "when the PackagesPolicy allows index?" do
    let(:packages_policy) { double("PackagesPolicy", index?: true) }

    it_allows :index?
  end

  context "when the PackagesPolicy denies index?" do
    let(:packages_policy) { double("PackagesPolicy", index?: false) }

    it_forbids :index?
  end

  describe "#resolve" do
    let(:packages_policy) { double("PackagesPolicy", resolve: ["dummy-relation"]) }

    it "scopes events to corresponding, visible packages" do
      expect(subject).to resolve([:packages, ["dummy-relation"]])
    end
  end
end
