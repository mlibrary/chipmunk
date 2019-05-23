# frozen_string_literal: true

class QueueItemPolicy < ResourcePolicy

  def show?
    package_policy.show?
  end

  def save?
    package_policy.save?
  end

  private

  def package_policy
    PackagePolicy.new(user, resource.package)
  end
end
