# frozen_string_literal: true

require "agent_resolver"

module Swapmeet
  RSpec.describe AgentResolver do
    subject(:agent_resolver) do
      described_class.new
    end

    def fake_attrs(attrs)
      double(:attrs, all: attrs)
    end

    def agent_from(type:, id:)
      Checkpoint::Agent.from(OpenStruct.new(agent_type: type, agent_id: id))
    end

    describe "#resolve" do
      let(:actor) { double(:user, identity: attrs) }
      let(:base_agent) { Checkpoint::Agent.from(actor) }

      context "with some attributes" do
        subject(:agent_resolver) do
          described_class.new
        end

        let(:attrs) { fake_attrs("foo" => "bar") }
        let(:agent) { agent_from(type: "foo", id: "bar") }

        it "turns the attributes into agents" do
          resolved_agents = agent_resolver.resolve(actor)
          expect(resolved_agents).to contain_exactly(base_agent, agent)
        end
      end

      context "with some different attributes" do
        let(:attrs) { fake_attrs("baz" => "quux") }
        let(:agent) { agent_from(type: "baz", id: "quux") }

        it "turns the attributes into agents" do
          resolved_agents = agent_resolver.resolve(actor)
          expect(resolved_agents).to contain_exactly(base_agent, agent)
        end
      end

      context "with a multi-value attribute" do
        let(:attrs) { fake_attrs("foo" => ["bar", "baz"]) }
        let(:agents) do
          [base_agent,
           agent_from(type: "foo", id: "bar"),
           agent_from(type: "foo", id: "baz")]
        end

        it "returns two agents" do
          resolved_agents = agent_resolver.resolve(actor)
          expect(resolved_agents.length).to eq(agents.length)
          expect(resolved_agents).to contain_exactly(*agents)
        end
      end
    end
  end
end
