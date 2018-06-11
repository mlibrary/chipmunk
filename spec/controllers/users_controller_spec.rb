# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "GET #login" do
    context "with X-Remote-user" do
      before(:each) { request.headers.merge!("X-Remote-User" => "someuser") }

      context "with session[:return_to]" do
        before(:each) { session[:return_to] = "/something" }

        it "redirects the user to the saved location" do
          session[:return_to] = "/something"
          get :login

          expect(response).to redirect_to("/something")
        end

        it "empties session[:return_to]" do
          session[:return_to] = "/something"
          get :login

          expect(session[:return_to]).to be nil
        end
      end

      context "with no return_to" do
        it "redirects to /v1/packages" do
          get :login
          expect(response).to redirect_to("/v1/packages")
        end
      end
    end
  end
end
