# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  # doesn't matter what, just needs to exist
  AN_EXISTING_TEMPLATE = "v1/audits/show"

  controller do
    def something
      render AN_EXISTING_TEMPLATE
      @something = "success"
    end

    def unauthorized
      raise NotAuthorizedError
    end

    def not_found
      raise Chipmunk::FileNotFoundError
    end
  end

  let(:auth_header) { {} }
  let(:remote_user_header) { {} }

  before(:each) do
    routes.draw do
      get "something" => "anonymous#something"
      get "unauthorized" => "anonymous#unauthorized"
      get "not_found" => "anonymous#not_found"
    end
    request.headers.merge! auth_header
    request.headers.merge! remote_user_header
  end

  shared_examples_for "an allowed request" do
    it { expect(response).to have_http_status(200) }
    it { expect(response).to render_template(AN_EXISTING_TEMPLATE) }

    it "executes the controller action" do
      expect(assigns(:something)).to eq("success")
    end

    it "sets user identity" do
      expect(controller.current_user.identity).to be_a(Hash)
    end
  end

  shared_examples_for "a forbidden request" do
    it { expect(response).to render_template(nil) }

    it "does not execute the controller action" do
      expect(assigns(:something)).to be(nil)
    end
  end

  shared_examples_for "respects Authorization header" do
    let(:key)   { Keycard::DigestKey.new }
    let!(:user) { Fabricate(:user, admin: true, api_key_digest: key.digest) }

    context "with valid Authorization header" do
      let(:auth_header) { user; { "Authorization" => "Token token=#{key}" } }

      it "sets current_user to the user corresponding to the token" do
        expect(controller.current_user).to eq(user)
      end

      it "sets identity[:username] to user.username" do
        expect(controller.current_user.identity[:username]).to eq(user.username)
      end

      it_behaves_like "an allowed request"
    end

    context "with invalid Authorization" do
      let(:auth_header) { { "Authorization" => "Token token=bad_token" } }

      it { expect(response).to have_http_status(401) }
      it_behaves_like "a forbidden request"
    end
  end

  context "with a request that will succeed if authenticated" do
    before(:each) { get :something }

    context "without X-Remote-User" do
      context "without Authorization" do
        it { expect(response).to redirect_to("/login") }
        it_behaves_like "a forbidden request"

        it "stores the requested return path in the session" do
          expect(session[:return_to]).to eq("/something")
        end
      end

      it_behaves_like "respects Authorization header"
    end

    context "with X-Remote-User" do
      let(:username) { ChipmunkFaker::Internet.user_name }
      let(:remote_user_header) { { "X-Remote-User" => username } }

      context "without Authorization" do
        it "sets current_user to a non-persisted user" do
          expect(controller.current_user.persisted?).to be false
        end
        it_behaves_like "an allowed request"
      end

      it_behaves_like "respects Authorization header"

      it "sets identity[:username] to the X-Remote-User value" do
        expect(controller.current_user.identity[:username]).to eq(username)
      end
    end
  end

  context "with a request that will fail even if authenticated" do
    let(:key)   { Keycard::DigestKey.new }
    let!(:user) { Fabricate(:user, admin: true, api_key_digest: key.digest) }
    let(:auth_header) { { "Authorization" => "Token token=#{key}" } }

    before(:each) { get :unauthorized }

    it { expect(response).to have_http_status(403) }
  end

  context "with a request that raises a FileNotFound error" do
    let(:key)   { Keycard::DigestKey.new }
    let!(:user) { Fabricate(:user, admin: true, api_key_digest: key.digest) }
    let(:auth_header) { { "Authorization" => "Token token=#{key}" } }

    before(:each) { get :not_found }

    it { expect(response).to have_http_status(404) }
  end
end
