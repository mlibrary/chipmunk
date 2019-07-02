# frozen_string_literal: true

require "rails_helper"
require "checkpoint_helper"

RSpec.describe "Login Worfklows", type: :request do
  context "when impersonation is allowed" do
    let(:user) { Fabricate(:user) }

    it "GET renders a login form" do
      get "/login"
      expect(response.content_type).to eq "text/html"
    end

    it "POST logs in as the specified user" do
      post "/login", params: { username: user.username }
      expect(session[:user_id]).to eq user.id
    end

    it "POST redirects to the front page" do
      post "/login", params: { username: user.username }
      expect(response).to redirect_to("/")
    end
  end

  context "when impersonation is disallowed" do
    around(:each) do |example|
      Chipmunk.config["allow_impersonation"] = false
      example.run
      Chipmunk.config["allow_impersonation"] = true
    end

    it "GET gives 401 Unauthorized" do
      get "/login"
      expect(response).to have_http_status(401)
    end

    it "POST gives 403 Forbidden" do
      post "/login", params: { username: "someuser" }
      expect(response).to have_http_status(403)
    end
  end

  context "with an API token header" do
    let(:api_key) { Keycard::DigestKey.new }
    let!(:user)   { Fabricate(:user, api_key_digest: api_key.digest) }
    let(:headers) { { "Authorization" => "Token token=#{api_key}" } }

    it "GET redirects to the front page" do
      get "/login", headers: headers
      expect(response).to redirect_to("/")
    end

    it "GET starts a session" do
      get "/login", headers: headers
      expect(session[:user_id]).to eq user.id
    end
  end

  context "with a single-sign-on user" do
    let(:user)    { Fabricate(:user) }
    let(:headers) { { "X-Remote-User" => user.username } }

    it "GET redirects to the front page" do
      get "/login", headers: headers
      expect(response).to redirect_to("/")
      expect(session[:user_id]).to eq user.id
    end
  end

  context "when there is already a session" do
    let(:user) { Fabricate(:user) }

    before(:each) do
      post "/login", params: { username: user.username }
    end

    it "GET redirects to the front page" do
      get "/login"
      expect(session[:user_id]).to eq user.id
      expect(response).to redirect_to("/")
    end
  end
end
