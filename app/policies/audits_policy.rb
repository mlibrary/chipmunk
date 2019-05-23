# frozen_string_literal: true

class AuditsPolicy < CollectionPolicy
  def base_scope
    Audit.all
  end

  def new?
    can?(:save, all_of_type(Audit))
  end

  def index?
    can?(:show, all_of_type(Audit))
  end

  def resolve
    ViewableResources.for(user, scope)
  end
end
