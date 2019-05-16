# frozen_string_literal: true

require "rails_helper"
require "fileutils"
require "support/examples/a_validation_integration"

RSpec.describe "video validation integration", integration: true do
  it_behaves_like "a validation integration" do
    let(:content_type) { "video" }
    let(:external_id) { "39015083611155" }
    let(:validation_script) { "validate_video.pl" }
    let(:expected_error) { /Error validating.*Unexpected files/m }
  end
end
