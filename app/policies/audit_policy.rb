# frozen_string_literal: true

class AuditPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def create?
    user.admin?
  end

  def index?
    user.admin?
  end

  def show?
    user.admin?
  end
end
