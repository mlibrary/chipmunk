# frozen_string_literal: true

class QueueItemsPolicy < CollectionPolicy

  def base_scope
    QueueItem.all
  end

  # fixme - should delegate to the related package

  def resolve
    scope.any_of( authority
      .which(user,:show)
      .select { |r| r.all? || r.type == 'QueueItem' }
      .map { |r| scope_for_resource(r) })
  end

  def scope_for_resource(resource)
    if resource.all?
      scope.all
    elsif resource.all_of_type?
      scope.with_type(resource.type)
    else
      scope.with_type_and_id(resource.type,resource.id)
    end
  end

  def new?
    # FIXME - should delegate to package
    can?(:create,all_of_type(QueueItem))
  end

  def index?
    # FIXME - should delegate to package
    can?(:show,all_of_type(QueueItem))
  end
end
