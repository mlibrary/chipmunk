# frozen_string_literal: true

require "rails_helper"
require "fileutils"

RSpec.describe "video validation integration", integration: true do
  it_behaves_like "a validation integration" do
    let(:content_type) { "video" }
    let(:external_id) { "39015083611155" }
    let(:expected_error) { /Error validating.*Unexpected files/m }
  end
end
