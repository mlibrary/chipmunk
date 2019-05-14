# frozen_string_literal: true

require "rails_helper"
require "checkpoint_helper"

RSpec.describe "GET /v1/packages", :checkpoint_transaction, type: :request do
  let(:key)  { Keycard::DigestKey.new }
  let!(:user) { Fabricate(:user, api_key_digest: key.digest) }

  let!(:video1) { Fabricate(:package, content_type: 'video') }
  let!(:video2) { Fabricate(:package, content_type: 'video') }
  let!(:audio1) { Fabricate(:package, content_type: 'audio') }

  let!(:qitem1) { Fabricate(:queue_item, package: video1) }
  let!(:qitem2) { Fabricate(:queue_item, package: video2) }
  let!(:qitem3) { Fabricate(:queue_item, package: audio1) }

  let(:headers) do
    { "Authorization"   => "Token token=#{key}" }
  end

  context "as a video content manager" do
    before(:each) do
      Services.checkpoint.grant!(user,
                                 Checkpoint::Credential::Role.new("content_manager"),
                                 Checkpoint::Resource::AllOfType.new("video"))
    end

    it "lists all video queue items & only video queue items" do
      get "/v1/queue", headers: headers

      expect(JSON.parse(response.body).map { |i| i["id"] }).to contain_exactly(qitem1.id, qitem2.id)
    end

    xit "lists nothing when asked for events from an audio package - pending PFDR-175"
  end

  context "as an admin" do
    before(:each) do
      Services.checkpoint.grant!(user,
                                 Checkpoint::Credential::Role.new('admin'),
                                 Checkpoint::Resource::AllOfAnyType.new)
    end

    it "lists all queue items" do
      get "/v1/queue", headers: headers

      expect(JSON.parse(response.body).map { |i| i["id"] }).to contain_exactly(qitem1.id, qitem2.id, qitem3.id)
    end
  end

  context "as a user with no grants" do
    it "returns a 403" do
      get "/v1/packages", headers: headers

      expect(response.status).to eq(403)
    end
  end
end
