# frozen_string_literal: true

class AuditPolicy < ResourcePolicy
  def show?
    user.admin?
  end
end
