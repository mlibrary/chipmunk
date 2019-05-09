# frozen_string_literal: true

class EventsPolicy < CollectionPolicy

  def index?
    PackagesPolicy.new(user,scope).index?
  end

  def base_scope
    Event.all
  end

  # FIXME - should delegate to the related package

  def resolve
    scope.any_of( authority
      .which(user,:show)
      .select { |r| r.all? || r.type == 'Event' }
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

end
