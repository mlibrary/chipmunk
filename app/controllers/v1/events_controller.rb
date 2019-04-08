# frozen_string_literal: true

module V1
  class EventsController < ResourceController
    collection_policy EventsPolicy

    def index
      policy = collection_policy.new(current_user, Event.package(params[:bag_id]))
      policy.authorize! :index?
      @events = policy.resolve
    end
  end
end
