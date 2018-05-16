# frozen_string_literal: true

class QueueItemsPolicy < CollectionPolicy

  def base_scope
    QueueItem.all
  end

  def index?
    true
  end

  def create?(request)
    user&.admin? || request&.user == user
  end

  def resolve
    if user.admin?
      scope.all
    else
      scope.joins(:package).where(packages: { user_id: user.id })
    end
  end
end
