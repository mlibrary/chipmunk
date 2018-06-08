# frozen_string_literal: true

class EventsPolicy < CollectionPolicy

  def index?
    user.known?
  end

  def base_scope
    Event.all
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
