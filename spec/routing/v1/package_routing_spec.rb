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
    end

    describe "v1/packages" do
      it "routes to #index" do
        expect(get: "/v1/packages").to route_to("v1/packages#index")
      end

      it "routes to #show" do
        expect(get: "/v1/packages/1").to route_to("v1/packages#show", bag_id: "1")
      end

      it "routes to #show" do
        expect(get: "/v1/packages/1/").to route_to("v1/packages#show", bag_id: "1")
      end

      it "routes to #sendfile" do
        expect(get: "/v1/packages/1/foo.jpg").to route_to("v1/packages#sendfile", bag_id: "1", file: "foo.jpg")
      end

      it "routes to #sendfile" do
        expect(get: "/v1/packages/1/somepath/bar.txt").to route_to("v1/packages#sendfile", bag_id: "1", file: "somepath/bar.txt")
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
