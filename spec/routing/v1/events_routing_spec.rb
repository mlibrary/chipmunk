# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::EventsController, type: :routing do
  describe "routing" do
    describe "v1/events" do
      it "routes to #index" do
        expect(get: "/v1/events").to route_to("v1/events#index")
      end
    end

    describe "v1/packages/:bag_id/events" do
      it "routes to #index" do
        expect(get: "/v1/packages/1/events").to route_to("v1/events#index", bag_id: "1")
      end
    end
  end
end
