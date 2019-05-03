# frozen_string_literal: true

class QueueItemPolicy < ResourcePolicy

  def create?
    return false unless QueueItemsPolicy.new(user).new?

    resource&.user == user || checkpoint_permits?(:create)
  end

  # Does it seem correct to delegate here, or should the controller use
  # PackagePolicy directly?
  def show?
    PackagePolicy.new(user,resource.package).show?
  end
end
