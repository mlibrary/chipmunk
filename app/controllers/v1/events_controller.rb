# frozen_string_literal: true

module V1
  class EventsController < ApplicationController
    def index
      @events = EventsPolicy.new(current_user, Event.package(params[:bag_id])).resolve
    end
  end
end
