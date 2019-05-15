# frozen_string_literal: true

class AuditsPolicy < CollectionPolicy
  def base_scope
    Audit.all
  end

  def new?
    can?(:new,all_of_type(Audit))
  end

  def index?
    can?(:index,all_of_type(Audit))
  end

  def resource_types
    ['Audit']
  end
end
