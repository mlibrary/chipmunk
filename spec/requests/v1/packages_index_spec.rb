# frozen_string_literal: true

require "rails_helper"
require "checkpoint_helper"

RSpec.describe "GET /v1/packages", :checkpoint_transaction, type: :request do
  let(:key)  { Keycard::DigestKey.new }
  let!(:user) { Fabricate(:user, api_key_digest: key.digest) }

  let!(:video1) { Fabricate(:package, content_type: 'video') }
  let!(:video2) { Fabricate(:package, content_type: 'video') }
  let!(:audio1) { Fabricate(:package, content_type: 'audio') }

  let(:headers) do
    {  "Authorization"   => "Token token=#{key}" }
  end

  context "as a video viewer" do
    # TODO: extract these granting methods from FakeUser?
    # TODO: allow specifying something more concise in grant!?
    before(:each) do
      Services.checkpoint.grant!(user,
                                 Checkpoint::Credential::Role.new("viewer"),
                                 Checkpoint::Resource::AllOfType.new("video"))
    end

    it "lists all video packages & only video packages" do
      get "/v1/packages", headers: headers

      expect(JSON.parse(response.body).map { |i| i["bag_id"] }).to contain_exactly(video1.bag_id, video2.bag_id)
    end
  end

  context "as an admin" do
    before(:each) do
      Services.checkpoint.grant!(user,
                                 Checkpoint::Credential::Role.new('admin'),
                                 Checkpoint::Resource::AllOfAnyType.new)
    end

    it "lists all packages" do
      get "/v1/packages", headers: headers

      expect(JSON.parse(response.body).map { |i| i["bag_id"] }).to contain_exactly(video1.bag_id, video2.bag_id, audio1.bag_id)
    end
  end

  context "as a user with no grants" do
    it "returns a 403" do
      get "/v1/packages", headers: headers

      expect(response.status).to eq(403)
    end
  end
end
