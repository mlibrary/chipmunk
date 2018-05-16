# frozen_string_literal: true

RSpec.shared_context "with bad auth token" do
  let(:user) { Fabricate(:user) }
  let(:auth_header) { { "Authorization" => "Token token=bad_token" } }
end
