# frozen_string_literal: true

class QueueItemsPolicy < CollectionPolicy

  def base_scope
    QueueItem.all
  end

  def index?
    user.known?
  end

  def new?
    user.known?
  end

  def resolve
    if user.admin?
      scope.all
    elsif user.known?
      scope.owned(user.id)
    else
      scope.none
    end
  end
end
