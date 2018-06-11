# frozen_string_literal: true

module V1
  class EventsController < ApplicationController
    def index
      policy = EventsPolicy.new(current_user, Event.package(params[:bag_id]))
      policy.authorize! :index?
      @events = policy.resolve
    end
  end
end
