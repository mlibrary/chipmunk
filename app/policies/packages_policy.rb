# frozen_string_literal: true

class PackagesPolicy < CollectionPolicy

  def index?
    true
  end

  def create?
    !user.nil?
  end

  def base_scope
    Package.all
  end

  def resolve
    if user.admin?
      scope.all
    else
      scope.where(user_id: user.id)
    end
  end
end
