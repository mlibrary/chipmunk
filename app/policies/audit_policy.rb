class AuditPolicy < ApplicationPolicy
  def create?
    user&.admin?
  end
end
