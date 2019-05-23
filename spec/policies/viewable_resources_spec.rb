# frozen_string_literal: true

RSpec.describe ViewableResources do
  subject(:scope) { described_class.new(actor: actor, relation: relation, authority: authority) }

  let(:actor)     { double(:actor) }
  let(:authority) { double(:authority) }

  context "with no grants" do
    let(:relation) { double(:relation, none: "none") }

    before(:each) do
      allow(authority).to receive(:which).with(actor, :show).and_return([])
    end

    it "scopes the relation to none" do
      expect(scope.all).to eq "none"
    end
  end

  context "with a global wildcard show grant" do
    let(:token) { Checkpoint::Resource::Token.all }
    let(:relation) { double(:relation, all: ["all"]) }

    before(:each) do
      allow(authority).to receive(:which).with(actor, :show).and_return([token])
    end

    it "scopes the relation to all" do
      expect(scope.all).to eq ["all"]
    end
  end

  context "with two global wildcard show grants" do
    let(:token1) { Checkpoint::Resource::Token.all }
    let(:token2) { Checkpoint::Resource::Token.all }
    let(:authority) { double(:authority) }
    let(:relation)  { FakeCollection.new }

    before(:each) do
      allow(authority).to receive(:which).with(actor, :show).and_return([token1, token2])
    end

    it "scopes the relation tall twice and joins with OR" do
      expect(scope.all.scopes).to contain_exactly(:all, :all)
    end
  end

  context "with a type wildcard show grant" do
    let(:token) { Checkpoint::Resource::Token.new("some-type", "(all)") }
    let(:relation) { FakeCollection.new(resource_types: ["some-type"]) }

    before(:each) do
      allow(authority).to receive(:which).with(actor, :show).and_return([token])
    end

    it "scopes the relation twice and joins with OR" do
      expect(scope.all.scopes).to eq [[:type, "some-type"]]
    end
  end

  context "with a type wildcard and a specific show grant" do
    let(:token1) { Checkpoint::Resource::Token.new("some-type", "(all)") }
    let(:token2) { Checkpoint::Resource::Token.new("foo", "id") }
    let(:authority) { double(:authority) }
    let(:relation)  { FakeCollection.new(resource_types: ["some-type", "foo"]) }

    before(:each) do
      allow(authority).to receive(:which).with(actor, :show).and_return([token1, token2])
    end

    it "scopes the relation twice and joins with OR" do
      expect(scope.all.scopes).to contain_exactly([:type, "some-type"], [:type_and_id, "foo", "id"])
    end
  end
end
