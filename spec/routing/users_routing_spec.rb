# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do
    describe "login" do
      it "routes to #login" do
        expect(get: "/login").to route_to("users#login")
      end
    end
  end
end
