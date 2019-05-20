# frozen_string_literal: true

class PackagePolicy < ResourcePolicy

  def show?
    can?(:show)
  end

  def create?
    can?(:create)
  end
end
