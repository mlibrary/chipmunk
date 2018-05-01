# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::AuditsController, type: :routing do
  describe "routing" do
    describe "v1/audits" do
      it "routes to #index" do
        expect(get: "/v1/audits").to route_to("v1/audits#index")
      end

      it "routes to #show" do
        expect(get: "/v1/audits/1").to route_to("v1/audits#show", id: "1")
      end
    end

    describe "post v1/audits" do
      it "routes to #create" do
        expect(post: "/v1/audits").to route_to("v1/audits#create")
      end
    end
  end
end
