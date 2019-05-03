# frozen_string_literal: true

class PackagePolicy < ResourcePolicy

  def show?
    checkpoint_permits?(:show)
  end
end
