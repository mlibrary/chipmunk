# frozen_string_literal: true

class AuditsPolicy < CollectionPolicy
  def base_scope
    Audit.all
  end

  def resolve
    if user.admin?
      scope.all
    else
      scope.none
    end
  end

  def create?
    user.admin?
  end

  def index?
    user.admin?
  end
end
