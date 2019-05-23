# frozen_string_literal: true

require "rails_helper"
require "checkpoint_helper"

RSpec.describe "GET /v1/packages", :checkpoint_transaction, type: :request do
  let(:key) { Keycard::DigestKey.new }
  let!(:user) { Fabricate(:user, api_key_digest: key.digest) }

  let!(:video_packages) { Array.new(2) { Fabricate(:package, content_type: "video") } }
  let!(:audio_package) { Fabricate(:package, content_type: "audio") }

  let!(:video_qitems) { video_packages.map {|p| Fabricate(:queue_item, package: p) } }
  let!(:all_qitems) { video_qitems + [Fabricate(:queue_item, package: audio_package)] }

  let(:headers) do
    { "Authorization" => "Token token=#{key}" }
  end

  context "as a video content manager" do
    before(:each) do
      Services.checkpoint.grant!(user,
        Checkpoint::Credential::Role.new("content_manager"),
        Checkpoint::Resource::AllOfType.new("video"))
    end

    it "lists all video queue items & only video queue items" do
      get "/v1/queue", headers: headers

      expect(JSON.parse(response.body).map {|i| i["id"] }).to contain_exactly(*video_qitems.map(&:id))
    end

    xit "lists nothing when asked for queue item from an audio package - pending PFDR-175"
  end

  context "as an admin" do
    before(:each) do
      Services.checkpoint.grant!(user,
        Checkpoint::Credential::Role.new("admin"),
        Checkpoint::Resource::AllOfAnyType.new)
    end

    it "lists all queue items" do
      get "/v1/queue", headers: headers

      expect(JSON.parse(response.body).map {|i| i["id"] }).to contain_exactly(*all_qitems.map(&:id))
    end
  end

  context "as a user with no grants" do
    it "returns a 403" do
      get "/v1/packages", headers: headers

      expect(response.status).to eq(403)
    end
  end
end
