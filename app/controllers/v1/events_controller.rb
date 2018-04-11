module V1
  class EventsController < ApplicationController
    def index
      @events = policy_scope(Event.bag(params[:bag_id]))
    end
  end
end
