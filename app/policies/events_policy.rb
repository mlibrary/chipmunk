# frozen_string_literal: true

class EventsPolicy < CollectionPolicy

  def index?
    PackagesPolicy.new(user,scope).index?
  end

  def base_scope
    Event.all
  end

  def resolve
    # n.b. the base scope is Event.all here, but since Event has the scame
    # scopes as Packages this will still work as intended.
    PackagesPolicy.new(user,scope).resolve
  end

end
