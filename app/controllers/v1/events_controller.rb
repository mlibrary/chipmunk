# frozen_string_literal: true

module V1
  class EventsController < ApplicationController
    def index
      @events = policy_scope(Event.package(params[:bag_id]))
    end
  end
end
