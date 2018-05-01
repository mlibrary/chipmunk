# frozen_string_literal: true

class AuditPolicy < ApplicationPolicy
  def create?
    user&.admin?
  end
end
