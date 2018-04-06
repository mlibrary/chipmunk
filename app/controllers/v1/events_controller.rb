module V1
  class EventsController < ApplicationController
    def index
      events = Event
      events = events.bag(params[:bag_id]) if params[:bag_id]

      @events = policy_scope(events)

    end
  end
end
