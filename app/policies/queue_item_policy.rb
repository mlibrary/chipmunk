# frozen_string_literal: true

class QueueItemPolicy < ResourcePolicy

  def create?
    return false unless QueueItemsPolicy.new(user).new?
    user&.admin? || resource&.user == user
  end

  def show?
    user&.admin? || resource&.user == user
  end
end
