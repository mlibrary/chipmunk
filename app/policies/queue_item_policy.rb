# frozen_string_literal: true

class QueueItemPolicy < ResourcePolicy

  def show?
    package_policy.show?
  end

  def create?
    package_policy.create?
  end

  private

  def package_policy
    PackagePolicy.new(user,resource.package)
  end
end
