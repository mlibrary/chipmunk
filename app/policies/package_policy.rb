# frozen_string_literal: true

class PackagePolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    user&.admin? || record&.user == user
  end

  def fixity_check?
    show?
  end

  def create?
    !user.nil?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
