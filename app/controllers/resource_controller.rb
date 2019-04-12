# frozen_string_literal: true

# Small base class for REST controllers that follow typical, consistent
# patterns for policies. The notion is that some controllers deal with
# resources of a single type and collections of that type. In these simple
# cases, the policy classes are mentioned once each, and used by method call
# throughout the controller. This keeps the identity coupling in one place and
# allows easier testing with post-instantiation, setter injection.
#
# The policy_double helper gives a very convient syntax for creating policy
# objects that answer true or false for given predicate and expect that
# authorize! is called properly.
#
# Usage:
#
#   1. Extend ResourceController and call collection_policy and resource_policy
#      in the class defintion to set the defaults (equivalent to defining
#      instance methods of the same name with caching assignments).
#   2. Call these readers anywhere you need one of the policies within the
#      rest of the controller.
#   3. Set a mock policy in a before block to test the controller.
#
# Example:
#
# class ThingsController < ResourceController
#   collection_policy ThingsPolicy
#   resource_policy ThingPolicy
# end
#
# RSpec.describe ThingsController do
#   before do
#     controller.resource_policy = policy_double('ThingPolicy', show?: false)
#   end
#
#   describe 'GET #show' do
#     context 'when the policy denies access' do
#       it 'responds with 403 Forbidden' do
#         ...
#       end
#     end
#   end
# end
class ResourceController < ApplicationController
  # Setters for the policy classes for resources managed by this
  # controller; primarily for injection in tests.
  attr_writer :collection_policy, :resource_policy

  # Declare the collection policy class for instances.
  #
  # This is intended for use at definition time of subclasses, to declare the
  # default policy by defining an overriding instance method on the subclass.
  # The actual policy to use for an instance can be set with the attr_writer.
  def self.collection_policy(policy)
    define_method(:collection_policy) { @collection_policy ||= policy }
  end

  # Declare the resource policy class for instances.
  #
  # This is intended for use at definition time of subclasses, to declare the
  # default policy by defining an overriding instance method on the subclass.
  # The actual policy to use for an instance can be set with the attr_writer.
  def self.resource_policy(policy)
    define_method(:resource_policy) { @resource_policy ||= policy }
  end

  # Declare abstract/base class policies as RejectAll
  collection_policy RejectAll
  resource_policy RejectAll
end
