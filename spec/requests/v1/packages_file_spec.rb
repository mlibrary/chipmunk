# frozen_string_literal: true

require "rails_helper"
require "checkpoint_helper"

RSpec.describe "GET /v1/packages/:bag_id/:file", :checkpoint_transaction, type: :request do
  let(:key)  { Keycard::DigestKey.new }
  let(:user) { Fabricate(:user, api_key_digest: key.digest) }
  let(:fixture_path) { fixture("video/upload/goodbag") }
  let(:package) { Fabricate(:stored_package, storage_path: "/video/upload/goodbag", content_type: "video") }

  let(:headers) do
    { "X-SendFile-Type" => "X-Sendfile",
      "Authorization"   => "Token token=#{key}" }
  end

  before(:each) do
    Services.checkpoint.grant!(user,
      Checkpoint::Credential::Role.new("viewer"),
      Checkpoint::Resource::AllOfType.new("video"))
  end

  it "can retrieve a file from the package with X-Sendfile" do
    get "/v1/packages/#{package.bag_id}/metadata.yaml", headers: headers
    expect(response.get_header("X-Sendfile")).to eq(File.join(fixture_path, "data", "metadata.yaml"))
  end
end
