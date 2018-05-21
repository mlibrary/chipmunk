# frozen_string_literal: true
require 'policy_errors'

class CollectionPolicy
  attr_reader :user

  def initialize(user, scope = nil)
    @user = user
    @scope = scope || base_scope
  end

  def base_scope
    ApplicationRecord.none
  end

  def resolve
    scope
  end

  def index?
    false
  end

  def create?
    false
  end

  def authorize!(action, message = nil)
    raise NotAuthorizedError.new(message) unless public_send(action)
  end

  private

    attr_reader :scope
end
