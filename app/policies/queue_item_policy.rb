# frozen_string_literal: true

class QueueItemPolicy < ResourcePolicy

  def show?
    user&.admin? || resource&.user == user
  end
end
