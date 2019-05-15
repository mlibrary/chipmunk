# frozen_string_literal: true

class EventsPolicy < CollectionPolicy

  def index?
    PackagesPolicy.new(user,scope).index?
  end

  def base_scope
    Event.all
  end

  def resolve
    scope.for_packages(PackagesPolicy.new(user).resolve)
  end

end
