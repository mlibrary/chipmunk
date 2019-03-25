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
# authorize! is called at least once.
#
# Usage:
#
#   1. Implement collection_policy and resource_policy with a caching
#      assignment of the normal policy.
#   2. Call these readers anywhere you need one of the policies within the
#      rest of the controller.
#   3. Set a mock policy in a before block to test the controller.
#
# Example:
#
# class ThingsController < ResourceController
#   def collection_policy
#     @collection_policy ||= ThingsPolicy
#   end
#
#   def resource_policy
#     @resource_policy ||= ThingPolicy
#   end
# end
#
# RSpec.describe ThingsController do
#   before do
#     controller.resource_policy = policy_double(show?: false)
#   end
#
#   describe 'GET #show' do
#     context 'with an unauthorized user' do
#       it 'rejects' do
#         ...
#       end
#     end
#   end
# end
class ResourceController < ApplicationController
  # The policy class for collections managed by this controller.
  attr_writer :collection_policy

  # The policy class for resources managed by this controller.
  attr_writer :resource_policy

  private

  def collection_policy
    RejectAll
  end

  def resource_policy
    RejectAll
  end
end
