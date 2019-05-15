# frozen_string_literal: true

class PackagesPolicy < CollectionPolicy

  def index?
    can?(:show,Package.of_any_type)
  end

  def new?
    can?(:create,Package.of_any_type)
  end

  def base_scope
    Package.all
  end

  def resource_types
    Package.content_types
  end

end
