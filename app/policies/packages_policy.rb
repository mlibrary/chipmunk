# frozen_string_literal: true

class PackagesPolicy < CollectionPolicy
  def index?
    can?(:show, Package.of_any_type)
  end

  def new?
    can?(:save, Package.of_any_type)
  end

  def base_scope
    Package.all
  end

  def resolve
    # Via the role map resolver, a user has access to:
    #   * All packages, if the user is an administrator
    #   * Packages of content types for which the user is a content manager
    #   * Packages of content types for which the user is authorized viewer
    #   * Any specific packages for which the user is granted access
    ViewableResources.for(user, scope)
  end

  def resource_types
    Package.content_types
  end
end
