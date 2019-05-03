# frozen_string_literal: true

class AuditPolicy < ResourcePolicy
  def show?
    checkpoint_permits?(:show)
  end
end
