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

  def resolve
    showable_scopes { |r| Package.content_types.include?(r.type) }
  end

end
