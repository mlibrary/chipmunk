# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /v1/packages/:bag_id/:file", type: :request do
  let(:key)  { Keycard::DigestKey.new }
  let(:user) { Fabricate(:user, admin: false, api_key_digest: key.digest) }
  let(:fixture_path) { fixture("video/upload/goodbag") }
  let(:package) { Fabricate(:package, user: user, storage_location: fixture_path) }

  let(:headers) do
    { "X-SendFile-Type" => "X-Sendfile",
      "Authorization"   => "Token token=#{key}" }
  end

  it "can retrieve a file from the package with X-Sendfile" do
    get "/v1/packages/#{package.bag_id}/metadata.yaml", headers: headers
    expect(response.get_header("X-Sendfile")).to eq(File.join(fixture_path, "data", "metadata.yaml"))
  end
end
