# frozen_string_literal: true

# A fake policy class that generates doubles for instances with configured
# responses and expectations.
#
# See {policy_double} for the typical, convenient usage.
class PolicyDouble
  include RSpec::Mocks::ExampleMethods

  attr_reader :name, :actions, :scope, :block

  def initialize(name, actions, scope = nil, &block)
    @name = name
    @actions = actions
    @scope = scope
    @block = block
  end

  def new(*new_policy_args)
    instance_double(name).tap do |policy|
      setup_actions(policy)
      setup_scope(policy, scope)
      setup_block(policy, *new_policy_args)
    end
  end

  private

  def setup_actions(policy)
    actions.each do |name, value|
      allow(policy).to receive(name.to_sym).and_return(value)
      expect(policy).to receive(:authorize!).with(name)
    end
  end

  def setup_scope(policy, scope)
    allow(policy).to receive(:resolve).and_return(scope) if scope
  end

  def setup_block(policy, *new_policy_args)
    if block
      block.call(policy, *new_policy_args)
    else
      allow(policy).to receive(:authorize!) do |action|
        raise NotAuthorizedError unless policy.send(action)
      end
    end
  end
end

# Create a convenient policy double.
#
# The simplest construct is to supply only a hash of predicates and whether
# they should return true or false. The double returned will expect that
# authorize! is called and will raise unless the predicate is truthy.
#
# Example:
#
# let(:policy) { policy_double(show?: true) }
#
# It does not expect that the specific predicate is authorized, but the
# expectation will fail if at least one present-and-truthy predicate is
# authorized.
#
# If more detailed control is needed, a block can be supplied. If this happens,
# the authorize! expectation is not set automatically and the block is called
# each time a new policy instance is created. The first parameter is the double
# itself and the rest are what is passed to the policy constructor. You can
# set more detailed responses and expectations on the policy instance here.
#
# Example:
#
# controller.resource_policy = policy_double do |policy|
#   allow(policy).to receive(:show?).and_return(true)
#   expect(policy).to receive(:authorize!).with(:show?)
# end
#
# Note that this example is illustrating the mechanism more than a suggested
# pattern. It is equivalent to the shorter form. An example of where this
# mechanism may be more useful is a case where multiple permissions must be
# authorized for a given controller action.
def policy_double(name, actions = {}, &block)
  PolicyDouble.new(name, actions, &block)
end

def collection_policy_double(name, scope, actions = {}, &block)
  PolicyDouble.new(name, actions, scope, &block)
end

def new_permit(agent, credential, resource, zone: Checkpoint::DB::Permit.default_zone)
  Checkpoint::DB::Permit.from(agent, credential, resource, zone: zone)
end

def agent(type: "user", id: "userid")
  actor = double("actor", agent_type: type, id: id)
  Checkpoint::Agent.new(actor)
end

def make_role(name)
  Checkpoint::Credential::Role.new(name)
end

def make_permission(name)
  Checkpoint::Credential::Permission.new(name)
end

def all_resources
  Checkpoint::Resource.all
end

def resource(type: "resource", id: 1)
  entity = double("entity", resource_type: type, id: id)
  Checkpoint::Resource.from(entity)
end
