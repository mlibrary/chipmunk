# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::PackagesController, type: :routing do
  describe "routing" do
    describe "v1/bags" do
      it "routes to #index" do
        expect(get: "/v1/bags").to route_to("v1/packages#index")
      end

      it "routes to #show" do
        expect(get: "/v1/bags/1").to route_to("v1/packages#show", bag_id: "1")
      end

      it "routes to #fixity_check" do
        expect(post: "/v1/bags/1/fixity_check").to route_to("v1/packages#fixity_check", bag_id: "1")
      end
    end

    describe "v1/packages" do
      it "routes to #index" do
        expect(get: "/v1/packages").to route_to("v1/packages#index")
      end

      it "routes to #show" do
        expect(get: "/v1/packages/1").to route_to("v1/packages#show", bag_id: "1")
      end

      it "routes to #fixity_check" do
        expect(post: "/v1/packages/1/fixity_check").to route_to("v1/packages#fixity_check", bag_id: "1")
      end
    end

    describe "v1/requests" do
      it "routes to #index" do
        expect(get: "/v1/requests").to route_to("v1/packages#index")
      end

      it "routes to #show" do
        expect(get: "/v1/requests/1").to route_to("v1/packages#show", bag_id: "1")
      end

      it "routes to #create" do
        expect(post: "/v1/requests").to route_to("v1/packages#create")
      end
    end
  end
end
