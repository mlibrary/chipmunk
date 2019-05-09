# frozen_string_literal: true

require "policy_errors"

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

  def new?
    false
  end

  def authorize!(action, message = nil)
    raise NotAuthorizedError, message unless public_send(action)
  end

  protected

  def authority
    Services.checkpoint
  end

  def can?(action,resource)
    Checkpoint::Query::ActionPermitted.new(user, action, resource, authority: authority).true?
  end

  def all_of_type(type)
    resource = Checkpoint::Resource::AllOfType.new(type)
  end

  private

  attr_reader :scope
end
