# frozen_string_literal: true

require "policy_errors"

class CollectionPolicy
  attr_reader :user

  def initialize(user, scope = nil)
    @user = user
    @scope = scope || base_scope
  end

  # This should potentially move to private, requiring resolve from outside
  def base_scope
    ApplicationRecord.none
  end

  def resolve
    scope.all
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

  def can?(action, resource)
    Checkpoint::Query::ActionPermitted.new(user, action, resource, authority: authority).true?
  end

  def all_of_type(type)
    Checkpoint::Resource::AllOfType.new(type)
  end

  def scope_for_resource(token)
    if token.all?
      scope.all
    elsif token.all_of_type?
      scope.with_type(token.type)
    else
      scope.with_type_and_id(token.type, token.id)
    end
  end

  def resource_types
    []
  end

  private

  attr_reader :scope
end
