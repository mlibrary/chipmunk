
# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::AuditController, type: :routing do
  describe "routing" do
    describe "v1/audit" do
      it "routes to #index" do
        expect(get: "/v1/audit").to route_to("v1/audit#index")
      end
      it "routes to #create" do
        expect(post: "/v1/audit").to route_to("v1/audit#create")
      end
    end
  end
end
