# frozen_string_literal: true

class AuditsPolicy < CollectionPolicy
  def base_scope
    Audit.all
  end

  def resolve
    scope.any_of( authority
      .which(user,:show)
      .select { |r| r.all? || r.type == 'Audit' }
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

  def new?
    can?(:new,all_of_type(Audit))
  end

  def index?
    can?(:index,all_of_type(Audit))
  end
end
