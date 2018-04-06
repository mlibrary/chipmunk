# frozen_string_literal: true

class EventPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        # non-privileged users are allowed to see events relating to any bags
        # they own, regardless of who created the event
        scope.joins(:bag).where("bags.user_id": user.id)
      end
    end
  end

end
