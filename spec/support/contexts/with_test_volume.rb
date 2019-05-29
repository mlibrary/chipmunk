# frozen_string_literal: true

RSpec.shared_context "with test volume" do
  before(:each) do
    volume = Volume.new(name: "test", package_type: Chipmunk::Bag, root_path: Rails.root/"spec/support/fixtures")
    allow(Services.storage).to receive(:for) do |package|
      volume.get(package.storage_path)
    end
  end
end
