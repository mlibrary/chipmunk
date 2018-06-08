# frozen_string_literal: true

class PackagesPolicy < CollectionPolicy

  def index?
    user.known?
  end

  def create?
    user.known?
  end

  def base_scope
    Package.all
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
