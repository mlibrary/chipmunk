# frozen_string_literal: true

require "rails_helper"
require "checkpoint_helper"

RSpec.describe "GET /v1/events", :checkpoint_transaction, type: :request do
  let(:key) { Keycard::DigestKey.new }
  let!(:user) { Fabricate(:user, api_key_digest: key.digest) }

  let!(:video) { Fabricate(:package, content_type: "video") }
  let!(:audio) { Fabricate(:package, content_type: "audio") }

  let!(:video_events) { Array.new(2) { Fabricate(:event, package: video) } }
  let!(:audio_events) { Array.new(2) { Fabricate(:event, package: audio) } }

  let(:headers) do
    { "Authorization" => "Token token=#{key}" }
  end

  context "as an audio content manager" do
    before(:each) do
      Services.checkpoint.grant!(user,
        Checkpoint::Credential::Role.new("content_manager"),
        Checkpoint::Resource::AllOfType.new("audio"))
    end

    it "lists all events from audio packages" do
      get "/v1/events", headers: headers

      actual = JSON.parse(response.body).map {|event| event["id"] }

      expect(actual).to contain_exactly(*audio_events.map(&:id))
    end

    xit "lists nothing when asked for events from a video package - pending PFDR-175"
  end

  context "as an admin" do
    before(:each) do
      Services.checkpoint.grant!(user,
        Checkpoint::Credential::Role.new("admin"),
        Checkpoint::Resource::AllOfAnyType.new)
    end

    it "lists all events" do
      get "/v1/events", headers: headers

      actual = JSON.parse(response.body).map {|event| event["id"] }
      all_events = audio_events + video_events

      expect(actual).to contain_exactly(*all_events.map(&:id))
    end
  end

  context "as a user with no grants" do
    it "returns a 403" do
      get "/v1/events", headers: headers

      expect(response.status).to eq(403)
    end
  end
end
