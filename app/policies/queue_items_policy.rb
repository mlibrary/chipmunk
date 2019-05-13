# frozen_string_literal: true

class QueueItemsPolicy < CollectionPolicy

  def index?
    PackagesPolicy.new(user,scope).index?
  end

  def new?
    PackagesPolicy.new(user,scope).new?
  end

  def base_scope
    QueueItem.all
  end

  # fixme - should delegate to the related package

  def resolve
    PackagesPolicy.new(user,scope).resolve
  end

end
