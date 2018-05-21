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

  def authorize!(action, message = nil)
    raise NotAuthorizedError.new(message) unless public_send(action)
  end
end
