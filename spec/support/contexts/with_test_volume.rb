# frozen_string_literal: true

RSpec.shared_context "with test volume" do
  before(:each) do
    volume = Volume.new(name: "test", format: :bag, root_path: Rails.root/"spec/support/fixtures")
    allow(Services.volumes).to receive(:find).with("test").and_return(volume)
  end
end
