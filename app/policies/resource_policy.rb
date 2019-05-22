# frozen_string_literal: true

class ResourcePolicy
  attr_reader :user, :resource

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  def show?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def save?
    false
  end

  def authorize!(action, message = nil)
    raise NotAuthorizedError, message unless public_send(action)
  end

  protected

  def can?(action)
    Checkpoint::Query::ActionPermitted.new(user, action, resource, authority: authority).true?
  end

  def authority
    Services.checkpoint
  end
end
