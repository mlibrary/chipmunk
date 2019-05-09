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
    scope.any_of( authority
      .which(user,:show)
      .select { |r| r.all? || Package.content_types.include?(r.type) }
      .map { |r| scope_for_resource(r) })
  end

  def scope_for_resource(resource)
    if resource.all?
      scope.all
    elsif resource.all_of_type?
      scope.with_type(resource.type)
    else
      scope.with_type_and_id(resource.type,resource.id)
    end
  end

end
