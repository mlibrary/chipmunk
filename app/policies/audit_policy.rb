# frozen_string_literal: true

class AuditPolicy < ResourcePolicy
  def show?
    can?(:show)
  end

  def save?
    can?(:save)
  end
end
