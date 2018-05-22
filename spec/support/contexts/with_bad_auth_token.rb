# frozen_string_literal: true

RSpec.shared_context "with bad auth token" do
  let(:user) { Fabricate(:user) }
end
